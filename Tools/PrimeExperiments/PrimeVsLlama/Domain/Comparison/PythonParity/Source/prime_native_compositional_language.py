#!/usr/bin/env python3
"""Ergentics-owned symbolic language for the native Prime mechanics canary.

The language is deliberately small and exact. It tests whether a randomly
initialized decoder can learn ordered composition over a finite algebra
without importing text, a tokenizer, or pretrained weights. It is not an
English corpus and cannot establish product language quality.
"""
from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import Iterable


SCHEMA_VERSION = "1"
LANGUAGE_ID = "ergentics_prime_z8_composition_v1"
MODULUS = 8

BOS = 1
APPLY = 2
ANSWER = 3
CONTEXT = 4
VALUE_BASE = 16
OP_INCREMENT = 32
OP_DECREMENT = 33
OP_NEGATE = 34
OPERATIONS = (OP_INCREMENT, OP_DECREMENT, OP_NEGATE)


@dataclass(frozen=True)
class Row:
    row_id: str
    split: str
    start: int
    operations: tuple[int, ...]
    input_ids: tuple[int, ...]
    target_id: int

    def canonical(self) -> dict:
        return {
            "input_ids": list(self.input_ids),
            "operations": list(self.operations),
            "row_id": self.row_id,
            "split": self.split,
            "start": self.start,
            "target_id": self.target_id,
        }


def value_token(value: int) -> int:
    if not 0 <= value < MODULUS:
        raise ValueError(f"value must be in Z/{MODULUS}Z: {value}")
    return VALUE_BASE + value


def apply_operation(value: int, operation: int) -> int:
    if operation == OP_INCREMENT:
        return (value + 1) % MODULUS
    if operation == OP_DECREMENT:
        return (value - 1) % MODULUS
    if operation == OP_NEGATE:
        return (-value) % MODULUS
    raise ValueError(f"unknown operation token: {operation}")


def evaluate(start: int, operations: Iterable[int]) -> int:
    value = start
    for operation in operations:
        value = apply_operation(value, operation)
    return value


def _split(start: int, first: int, second: int) -> str:
    del start
    # Hold out entire ordered-operation families across every value. This
    # prevents a changed value from silently turning a mutation into a train
    # row and directly tests composition of primitives seen only separately.
    pair = (first, second)
    if pair in {
        (OP_INCREMENT, OP_DECREMENT),
        (OP_DECREMENT, OP_INCREMENT),
        (OP_INCREMENT, OP_NEGATE),
        (OP_NEGATE, OP_INCREMENT),
    }:
        return "holdout"
    if pair == (OP_NEGATE, OP_NEGATE):
        return "validation"
    return "train"


def build_rows() -> list[Row]:
    rows: list[Row] = []

    # One-step closure keeps every primitive and value grounded in train.
    for start in range(MODULUS):
        for operation in OPERATIONS:
            result = evaluate(start, (operation,))
            rows.append(
                Row(
                    row_id=f"train-one-{start}-{operation}",
                    split="train",
                    start=start,
                    operations=(operation,),
                    input_ids=(
                        BOS,
                        APPLY,
                        value_token(start),
                        operation,
                        ANSWER,
                    ),
                    target_id=value_token(result),
                )
            )
            rows.append(
                Row(
                    row_id=f"train-context-one-{start}-{operation}",
                    split="train",
                    start=start,
                    operations=(operation,),
                    input_ids=(
                        BOS,
                        CONTEXT,
                        APPLY,
                        value_token(start),
                        operation,
                        ANSWER,
                    ),
                    target_id=value_token(result),
                )
            )

    for start in range(MODULUS):
        for first in OPERATIONS:
            for second in OPERATIONS:
                operations = (first, second)
                split = _split(start, first, second)
                result = evaluate(start, operations)
                rows.append(
                    Row(
                        row_id=f"{split}-two-{start}-{first}-{second}",
                        split=split,
                        start=start,
                        operations=operations,
                        input_ids=(
                            BOS,
                            APPLY,
                            value_token(start),
                            first,
                            second,
                            ANSWER,
                        ),
                        target_id=value_token(result),
                    )
                )
                if split == "train":
                    rows.append(
                        Row(
                            row_id=(
                                f"train-context-two-{start}-{first}-{second}"
                            ),
                            split="train",
                            start=start,
                            operations=operations,
                            input_ids=(
                                BOS,
                                CONTEXT,
                                APPLY,
                                value_token(start),
                                first,
                                second,
                                ANSWER,
                            ),
                            target_id=value_token(result),
                        )
                    )

    _validate(rows)
    return rows


def _validate(rows: list[Row]) -> None:
    if len({row.row_id for row in rows}) != len(rows):
        raise AssertionError("row IDs are not unique")

    semantic_keys: dict[str, set[tuple[int, tuple[int, ...]]]] = {}
    for row in rows:
        semantic_keys.setdefault(row.split, set()).add(
            (row.start, row.operations)
        )
        if row.target_id != value_token(evaluate(row.start, row.operations)):
            raise AssertionError(f"incorrect target: {row.row_id}")

    for left, right in (
        ("train", "validation"),
        ("train", "holdout"),
        ("validation", "holdout"),
    ):
        if semantic_keys[left] & semantic_keys[right]:
            raise AssertionError(f"{left}/{right} semantic leakage")

    train = [row for row in rows if row.split == "train"]
    train_values = {row.start for row in train}
    train_operations = {
        operation for row in train for operation in row.operations
    }
    if train_values != set(range(MODULUS)):
        raise AssertionError("train does not cover every value")
    if train_operations != set(OPERATIONS):
        raise AssertionError("train does not cover every operation")
    if not all(any(row.split == split for row in rows) for split in (
        "train",
        "validation",
        "holdout",
    )):
        raise AssertionError("one or more splits are empty")


def split_rows(rows: list[Row], split: str) -> list[Row]:
    return [row for row in rows if row.split == split]


def canonical_sha256(rows: Iterable[Row]) -> str:
    payload = json.dumps(
        [row.canonical() for row in rows],
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def mutation_rows(rows: Iterable[Row]) -> list[Row]:
    """Render held-out semantics through a trained neutral syntax mutation."""
    mutations: list[Row] = []
    for row in rows:
        mutations.append(
            Row(
                row_id=f"mutation-context-{row.row_id}",
                split="mutation",
                start=row.start,
                operations=row.operations,
                input_ids=(
                    BOS,
                    CONTEXT,
                    APPLY,
                    value_token(row.start),
                    *row.operations,
                    ANSWER,
                ),
                target_id=row.target_id,
            )
        )
    if not mutations:
        raise AssertionError("mutation suite is empty")
    return mutations


def invariant_counts(rows: Iterable[Row]) -> dict[str, int]:
    rows = list(rows)
    conservation = 0
    reversibility = 0
    order_sensitive = 0
    for row in rows:
        if len(row.operations) != 2:
            continue
        result = evaluate(row.start, row.operations)
        if result == row.start:
            conservation += 1
        inverse_pairs = {
            (OP_INCREMENT, OP_DECREMENT),
            (OP_DECREMENT, OP_INCREMENT),
            (OP_NEGATE, OP_NEGATE),
        }
        if row.operations in inverse_pairs and result == row.start:
            reversibility += 1
        if evaluate(row.start, reversed(row.operations)) != result:
            order_sensitive += 1
    return {
        "conservation_rows": conservation,
        "order_sensitive_rows": order_sensitive,
        "reversibility_rows": reversibility,
        "row_count": len(rows),
    }
