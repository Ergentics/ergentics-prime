#!/usr/bin/env python3
"""Optional Python cross-runtime reference for the historical 10M canary.

This file cannot produce primary native-language evidence. The accepted
executor and recommendation path are Swift/MLX/Metal. When explicitly enabled,
this reference starts random weights and consumes the Ergentics-generated
mechanics language without imported model weights, external text, or a custom
Metal kernel.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import time
from pathlib import Path

import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim
from mlx.utils import tree_flatten
from mlx_lm.models.llama import Model, ModelArgs

from prime_native_compositional_language import (
    LANGUAGE_ID,
    SCHEMA_VERSION,
    Row,
    canonical_sha256,
    evaluate,
    invariant_counts,
    split_rows,
    value_token,
)


PROFILE = {
    "profile_id": "ergentics_prime_poc_10m_v1",
    "vocab_size": 16_384,
    "model_dimension": 256,
    "layer_count": 8,
    "attention_heads": 4,
    "head_dimension": 64,
    "feed_forward_dimension": 640,
    "sequence_length_contract": 2_048,
    "rope_base": 10_000.0,
}
EXPECTED_PARAMETER_COUNT = 10_227_968
REPORT_SCHEMA_VERSION = "2"


def make_model(seed: int) -> Model:
    mx.random.seed(seed)
    args = ModelArgs(
        model_type="llama",
        hidden_size=PROFILE["model_dimension"],
        num_hidden_layers=PROFILE["layer_count"],
        intermediate_size=PROFILE["feed_forward_dimension"],
        num_attention_heads=PROFILE["attention_heads"],
        num_key_value_heads=PROFILE["attention_heads"],
        head_dim=PROFILE["head_dimension"],
        rms_norm_eps=1e-5,
        vocab_size=PROFILE["vocab_size"],
        max_position_embeddings=PROFILE["sequence_length_contract"],
        rope_theta=PROFILE["rope_base"],
        tie_word_embeddings=True,
    )
    model = Model(args)
    mx.eval(model.parameters())
    return model


def parameter_count(model: nn.Module) -> int:
    return sum(
        parameter.size
        for _, parameter in tree_flatten(model.parameters())
    )


def loss_fn(model: Model, inputs: mx.array, targets: mx.array) -> mx.array:
    logits = model(inputs)[:, -1, :]
    return nn.losses.cross_entropy(
        logits,
        targets,
        reduction="mean",
    )


def grouped(rows: list[Row]) -> dict[int, list[Row]]:
    groups: dict[int, list[Row]] = {}
    for row in rows:
        groups.setdefault(len(row.input_ids), []).append(row)
    return groups


def batch_arrays(rows: list[Row]) -> tuple[mx.array, mx.array]:
    return (
        mx.array([list(row.input_ids) for row in rows], dtype=mx.int32),
        mx.array([row.target_id for row in rows], dtype=mx.int32),
    )


def evaluate_rows(
    model: Model,
    rows: list[Row],
) -> tuple[float, float, list[dict]]:
    if not rows:
        raise ValueError("evaluation rows must not be empty")
    model.eval()
    losses: list[float] = []
    results: list[dict] = []
    correct = 0
    for length_rows in grouped(rows).values():
        inputs, targets = batch_arrays(length_rows)
        logits = model(inputs)[:, -1, :]
        losses_array = nn.losses.cross_entropy(
            logits,
            targets,
            reduction="none",
        )
        predictions = mx.argmax(logits, axis=-1)
        mx.eval(losses_array, predictions)
        row_losses = losses_array.tolist()
        row_predictions = predictions.tolist()
        for row, row_loss, prediction in zip(
            length_rows,
            row_losses,
            row_predictions,
        ):
            match = int(prediction) == row.target_id
            correct += int(match)
            losses.append(float(row_loss))
            results.append(
                {
                    "row_id": row.row_id,
                    "prediction": int(prediction),
                    "target": row.target_id,
                    "match": match,
                }
            )
    return sum(losses) / len(losses), correct / len(rows), results


def transition_predictions(
    model: Model,
    rows: list[Row],
) -> dict[tuple[int, int], int]:
    primitive_rows = [
        row
        for row in split_rows(rows, "train")
        if len(row.operations) == 1
        and len(row.input_ids) == 5
    ]
    _, _, results = evaluate_rows(model, primitive_rows)
    by_id = {item["row_id"]: item["prediction"] for item in results}
    return {
        (row.start, row.operations[0]): by_id[row.row_id]
        for row in primitive_rows
    }


def engine_coupled_evaluation(
    model: Model,
    rows: list[Row],
    language_rows: list[Row],
) -> dict:
    """Compose two learned transitions outside the decoder.

    This is an independent boundary check, not a neural-composition pass. It
    measures whether Engine can safely retain composition authority while the
    neural model supplies only a learned primitive transition.
    """
    transitions = transition_predictions(model, language_rows)
    primitive_matches = 0
    primitive_results = []
    for (start, operation), prediction in transitions.items():
        target = value_token(evaluate(start, (operation,)))
        match = prediction == target
        primitive_matches += int(match)
        primitive_results.append(
            {
                "row_id": f"primitive-{start}-{operation}",
                "prediction": prediction,
                "target": target,
                "match": match,
            }
        )

    results = []
    matches = 0
    for row in rows:
        first, second = row.operations
        intermediate_token = transitions[(row.start, first)]
        if 16 <= intermediate_token < 24:
            intermediate = intermediate_token - 16
            final_token = transitions[(intermediate, second)]
        else:
            intermediate = None
            final_token = -1
        match = final_token == row.target_id
        matches += int(match)
        results.append(
            {
                "row_id": row.row_id,
                "intermediate": intermediate_token,
                "prediction": final_token,
                "target": row.target_id,
                "match": match,
            }
        )
    return {
        "primitive_accuracy": primitive_matches / len(transitions),
        "primitive_count": len(transitions),
        "primitive_results": primitive_results,
        "accuracy": matches / len(rows),
        "results": results,
    }


def load_language_manifest(path: Path) -> tuple[list[Row], list[Row]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("schema_version") != SCHEMA_VERSION:
        raise ValueError("Swift language manifest schema mismatch")
    if payload.get("language_id") != LANGUAGE_ID:
        raise ValueError("Swift language manifest language mismatch")

    def decode(items: list[dict]) -> list[Row]:
        return [
            Row(
                row_id=item["row_id"],
                split=item["split"],
                start=int(item["start"]),
                operations=tuple(int(x) for x in item["operations"]),
                input_ids=tuple(int(x) for x in item["input_ids"]),
                target_id=int(item["target_id"]),
            )
            for item in items
        ]

    rows = decode(payload["rows"])
    mutations = decode(payload["mutations"])
    if not rows or not mutations:
        raise ValueError("Swift language manifest is empty")
    return rows, mutations


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def max_logit_delta(left: mx.array, right: mx.array) -> float:
    delta = mx.max(mx.abs(left.astype(mx.float32) - right.astype(mx.float32)))
    mx.eval(delta)
    return float(delta.item())


def compare_parameters(left: nn.Module, right: nn.Module) -> dict:
    left_parameters = tree_flatten(left.parameters())
    right_parameters = tree_flatten(right.parameters())
    if [name for name, _ in left_parameters] != [
        name for name, _ in right_parameters
    ]:
        raise ValueError("parameter names differ")
    maxima = []
    equalities = []
    for (_, left_value), (_, right_value) in zip(
        left_parameters,
        right_parameters,
    ):
        if left_value.shape != right_value.shape:
            raise ValueError("parameter shapes differ")
        if left_value.dtype != right_value.dtype:
            raise ValueError("parameter dtypes differ")
        maxima.append(
            mx.max(
                mx.abs(
                    left_value.astype(mx.float32)
                    - right_value.astype(mx.float32)
                )
            )
        )
        equalities.append(mx.array_equal(left_value, right_value))
    delta = mx.max(mx.stack(maxima))
    mx.eval(delta, *equalities)
    return {
        "tensor_count": len(left_parameters),
        "exact": all(bool(value.item()) for value in equalities),
        "max_delta": float(delta.item()),
    }


def forward_contract(model: Model) -> dict:
    """Falsify an absent/bidirectional mask with a future-token mutation."""
    inputs = mx.array(
        [
            [1, 2, 16, 32, 3, 16],
            [1, 2, 16, 32, 34, 23],
        ],
        dtype=mx.int32,
    )
    model.eval()
    logits = model(inputs)
    finite = mx.all(mx.isfinite(logits))
    mx.eval(logits, finite)
    # The first four tokens are identical. Their logits must be exactly
    # invariant to mutations in positions four and five under a causal mask.
    causal_prefix_delta = max_logit_delta(
        logits[0, :4, :],
        logits[1, :4, :],
    )
    # The changed suffix must still have a measurable downstream effect, so a
    # constant-output implementation cannot satisfy the invariance check.
    suffix_effect_delta = max_logit_delta(
        logits[0, 5:, :],
        logits[1, 5:, :],
    )
    return {
        "logits_shape": list(logits.shape),
        "logits_finite": bool(finite.item()),
        "causal_prefix_max_logit_delta": causal_prefix_delta,
        "suffix_effect_max_logit_delta": suffix_effect_delta,
    }


def optimize(
    model: Model,
    args: argparse.Namespace,
    train_groups: dict[int, list[Row]],
    lengths: list[int],
) -> dict:
    rng = random.Random(args.seed)
    optimizer = optim.AdamW(
        learning_rate=args.learning_rate,
        weight_decay=args.weight_decay,
    )
    loss_and_grad = nn.value_and_grad(model, loss_fn)
    losses: list[float] = []
    first_gradient_norm: float | None = None
    started = time.monotonic()
    trained_tokens = 0
    for step in range(args.steps):
        length = lengths[step % len(lengths)]
        population = train_groups[length]
        selected = rng.choices(population, k=args.batch_size)
        inputs, targets = batch_arrays(selected)
        model.train()
        loss, gradients = loss_and_grad(model, inputs, targets)
        if step == 0:
            squared = [
                mx.sum(gradient.astype(mx.float32) ** 2)
                for _, gradient in tree_flatten(gradients)
            ]
            gradient_norm = mx.sqrt(mx.sum(mx.stack(squared)))
            mx.eval(gradient_norm)
            first_gradient_norm = float(gradient_norm.item())
        optimizer.update(model, gradients)
        mx.eval(model.parameters(), optimizer.state, loss)
        loss_value = float(loss.item())
        if not math.isfinite(loss_value):
            raise RuntimeError(f"non-finite loss at step {step}: {loss_value}")
        losses.append(loss_value)
        trained_tokens += inputs.size
        if time.monotonic() - started > args.max_seconds:
            raise RuntimeError(
                f"training exceeded max seconds at step {step}"
            )
    return {
        "losses": losses,
        "first_gradient_norm": first_gradient_norm,
        "elapsed_seconds": time.monotonic() - started,
        "trained_tokens": trained_tokens,
    }


def run(args: argparse.Namespace) -> dict:
    rows, mutations = load_language_manifest(args.language_manifest)
    train_rows = split_rows(rows, "train")
    validation_rows = split_rows(rows, "validation")
    holdout_rows = split_rows(rows, "holdout")
    train_groups = grouped(train_rows)
    lengths = sorted(train_groups)

    mx.reset_peak_memory()
    model = make_model(args.seed)
    observed_parameters = parameter_count(model)
    initial_forward = forward_contract(model)
    initial_embedding = model.model.embed_tokens.weight[:64]
    mx.eval(initial_embedding)

    initial_train_loss, initial_train_accuracy, _ = evaluate_rows(
        model,
        train_rows,
    )
    initial_holdout_loss, initial_holdout_accuracy, _ = evaluate_rows(
        model,
        holdout_rows,
    )

    primary = optimize(model, args, train_groups, lengths)
    losses = primary["losses"]
    first_gradient_norm = primary["first_gradient_norm"]
    train_seconds = primary["elapsed_seconds"]
    trained_tokens = primary["trained_tokens"]
    completed_steps = len(losses)

    final_train_loss, final_train_accuracy, _ = evaluate_rows(
        model,
        train_rows,
    )
    validation_loss, validation_accuracy, validation_results = evaluate_rows(
        model,
        validation_rows,
    )
    holdout_loss, holdout_accuracy, holdout_results = evaluate_rows(
        model,
        holdout_rows,
    )
    mutation_loss, mutation_accuracy, mutation_results = evaluate_rows(
        model,
        mutations,
    )
    engine_coupled = engine_coupled_evaluation(
        model,
        holdout_rows,
        rows,
    )
    final_forward = forward_contract(model)
    primary_peak_memory = mx.get_peak_memory()

    final_embedding = model.model.embed_tokens.weight[:64]
    embedding_delta = mx.linalg.norm(
        final_embedding.astype(mx.float32)
        - initial_embedding.astype(mx.float32)
    )
    mx.eval(embedding_delta)
    embedding_delta_value = float(embedding_delta.item())

    args.output.mkdir(parents=True, exist_ok=True)
    checkpoint = args.output / "prime-native-mechanics.safetensors"
    model.save_weights(str(checkpoint))
    checkpoint_hash = sha256_file(checkpoint)

    probe_inputs, _ = batch_arrays(holdout_rows[: min(4, len(holdout_rows))])
    original_logits = model(probe_inputs)[:, -1, :]
    repeated_logits = model(probe_inputs)[:, -1, :]
    mx.eval(original_logits, repeated_logits)
    repeated_inference_delta = max_logit_delta(
        original_logits,
        repeated_logits,
    )

    reloaded = make_model(args.seed + 1)
    reloaded.load_weights(str(checkpoint), strict=True)
    mx.eval(reloaded.parameters())
    reloaded_logits = reloaded(probe_inputs)[:, -1, :]
    mx.eval(reloaded_logits)
    checkpoint_reload_delta = max_logit_delta(
        original_logits,
        reloaded_logits,
    )
    checkpoint_reload_weights = compare_parameters(model, reloaded)

    # A second complete run proves that the seed controls initialization,
    # sampling, and the optimizer schedule—not merely that one trained model
    # returns the same inference twice. Metal reductions are also measured for
    # bitwise replay; capability gating uses independently regraded behavior
    # rather than pretending the GPU guarantees bitwise training determinism.
    replay_model = make_model(args.seed)
    replay_initial_forward = forward_contract(replay_model)
    replay_initial_train_loss, _, _ = evaluate_rows(
        replay_model,
        train_rows,
    )
    replay_initial_holdout_loss, _, _ = evaluate_rows(
        replay_model,
        holdout_rows,
    )
    replay = optimize(replay_model, args, train_groups, lengths)
    replay_losses = replay["losses"]
    (
        replay_final_train_loss,
        replay_final_train_accuracy,
        _,
    ) = evaluate_rows(replay_model, train_rows)
    (
        replay_validation_loss,
        replay_validation_accuracy,
        replay_validation_results,
    ) = evaluate_rows(replay_model, validation_rows)
    (
        replay_holdout_loss,
        replay_holdout_accuracy,
        replay_holdout_results,
    ) = evaluate_rows(replay_model, holdout_rows)
    (
        replay_mutation_loss,
        replay_mutation_accuracy,
        replay_mutation_results,
    ) = evaluate_rows(replay_model, mutations)
    replay_engine_coupled = engine_coupled_evaluation(
        replay_model,
        holdout_rows,
        rows,
    )
    replay_final_forward = forward_contract(replay_model)
    replay_logits = replay_model(probe_inputs)[:, -1, :]
    mx.eval(replay_logits)
    same_seed_replay_logit_delta = max_logit_delta(
        original_logits,
        replay_logits,
    )
    same_seed_replay_weights = compare_parameters(
        model,
        replay_model,
    )
    same_seed_replay_loss_delta = (
        max(
            abs(left - right)
            for left, right in zip(losses, replay_losses)
        )
        if len(losses) == len(replay_losses) and losses
        else math.inf
    )
    replay_checkpoint = (
        args.output / "prime-native-mechanics-replay.safetensors"
    )
    replay_model.save_weights(str(replay_checkpoint))
    replay_checkpoint_hash = sha256_file(replay_checkpoint)

    holdout_by_id = {row.row_id: row for row in holdout_rows}
    holdout_prediction_by_id = {
        item["row_id"]: item["prediction"] for item in holdout_results
    }
    conservation_ids = {
        row.row_id
        for row in holdout_rows
        if evaluate(row.start, row.operations) == row.start
    }
    order_sensitive_ids = {
        row.row_id
        for row in holdout_rows
        if len(row.operations) == 2
        and evaluate(row.start, reversed(row.operations))
        != evaluate(row.start, row.operations)
    }

    def subset_accuracy(ids: set[str]) -> float:
        if not ids:
            return 0.0
        matches = sum(
            holdout_prediction_by_id[row_id]
            == holdout_by_id[row_id].target_id
            for row_id in ids
        )
        return matches / len(ids)

    loss_decreased = final_train_loss < initial_train_loss
    gradient_valid = (
        first_gradient_norm is not None
        and math.isfinite(first_gradient_norm)
        and first_gradient_norm > 0
    )
    checkpoint_exact = checkpoint_reload_delta == 0
    checkpoint_weights_exact = (
        checkpoint_reload_weights["exact"]
        and checkpoint_reload_weights["max_delta"] == 0
    )
    repeated_inference_exact = repeated_inference_delta == 0
    same_seed_bitwise_replay_exact = (
        len(losses) == len(replay_losses)
        and same_seed_replay_loss_delta == 0
        and same_seed_replay_logit_delta == 0
        and same_seed_replay_weights["exact"]
        and same_seed_replay_weights["max_delta"] == 0
        and checkpoint_hash == replay_checkpoint_hash
    )
    replay_forward_grounded = (
        replay_initial_forward["logits_shape"]
            == [2, 6, PROFILE["vocab_size"]]
        and replay_final_forward["logits_shape"]
            == replay_initial_forward["logits_shape"]
        and replay_initial_forward["logits_finite"]
        and replay_final_forward["logits_finite"]
        and replay_initial_forward["causal_prefix_max_logit_delta"] == 0
        and replay_final_forward["causal_prefix_max_logit_delta"] == 0
        and replay_initial_forward["suffix_effect_max_logit_delta"] > 0
        and replay_final_forward["suffix_effect_max_logit_delta"] > 0
    )
    same_seed_behavioral_replay = (
        len(replay_losses) == args.steps
        and replay["first_gradient_norm"] is not None
        and math.isfinite(replay["first_gradient_norm"])
        and replay["first_gradient_norm"] > 0
        and replay_final_train_loss < replay_initial_train_loss
        and replay_final_train_accuracy >= 0.90
        and replay_engine_coupled["primitive_accuracy"] >= 0.95
        and replay_engine_coupled["accuracy"] >= 0.95
        and replay_holdout_accuracy < args.minimum_accuracy
        and replay_mutation_accuracy < args.minimum_mutation_accuracy
        and replay_forward_grounded
    )
    forward_grounded = (
        initial_forward["logits_shape"]
            == [2, 6, PROFILE["vocab_size"]]
        and final_forward["logits_shape"]
            == initial_forward["logits_shape"]
        and initial_forward["logits_finite"]
        and final_forward["logits_finite"]
        and initial_forward["causal_prefix_max_logit_delta"] == 0
        and final_forward["causal_prefix_max_logit_delta"] == 0
        and initial_forward["suffix_effect_max_logit_delta"] > 0
        and final_forward["suffix_effect_max_logit_delta"] > 0
    )
    mechanics_grounded = (
        observed_parameters == EXPECTED_PARAMETER_COUNT
        and completed_steps == args.steps
        and forward_grounded
        and gradient_valid
        and embedding_delta_value > 0
        and loss_decreased
        and checkpoint_exact
        and checkpoint_weights_exact
        and repeated_inference_exact
        and same_seed_behavioral_replay
    )
    compositional_grounded = (
        validation_accuracy >= args.minimum_accuracy
        and holdout_accuracy >= args.minimum_accuracy
        and mutation_accuracy >= args.minimum_mutation_accuracy
        and subset_accuracy(conservation_ids) >= args.minimum_accuracy
        and subset_accuracy(order_sensitive_ids) >= args.minimum_accuracy
    )
    outcome = (
        "GROUNDED"
        if mechanics_grounded and compositional_grounded
        else "ABSTAIN"
    )

    report = {
        "schema_version": REPORT_SCHEMA_VERSION,
        "outcome": outcome,
        "family_id": "ergentics_native_mlx_metal_compositional_canary",
        "profile": PROFILE,
        "language": {
            "language_id": LANGUAGE_ID,
            "ownership": "ergentics_generated",
            "external_corpus": False,
            "tokenizer": "fixed_symbol_ids_no_text_tokenizer",
            "manifest_sha256": canonical_sha256(rows),
            "train_manifest_sha256": canonical_sha256(train_rows),
            "validation_manifest_sha256": canonical_sha256(validation_rows),
            "holdout_manifest_sha256": canonical_sha256(holdout_rows),
            "train_rows": len(train_rows),
            "validation_rows": len(validation_rows),
            "holdout_rows": len(holdout_rows),
            "mutation_rows": len(mutations),
            "holdout_invariants": invariant_counts(holdout_rows),
        },
        "implementation": {
            "framework": "mlx",
            "model_implementation": "mlx_lm.models.llama.Model",
            "standard_primitives": True,
            "custom_metal_kernels": False,
            "imported_base_weights": False,
            "random_initialization": True,
            "observed_parameter_count": observed_parameters,
            "expected_parameter_count": EXPECTED_PARAMETER_COUNT,
        },
        "training": {
            "seed": args.seed,
            "requested_steps": args.steps,
            "completed_steps": completed_steps,
            "batch_size": args.batch_size,
            "learning_rate": args.learning_rate,
            "weight_decay": args.weight_decay,
            "elapsed_seconds": train_seconds,
            "tokens_per_second": (
                trained_tokens / train_seconds if train_seconds > 0 else 0
            ),
            "peak_memory_bytes": primary_peak_memory,
            "first_gradient_norm": first_gradient_norm,
            "embedding_delta_l2": embedding_delta_value,
            "sampled_first_loss": losses[0] if losses else None,
            "sampled_final_loss": losses[-1] if losses else None,
        },
        "forward": {
            "logits_shape": initial_forward["logits_shape"],
            "initial_logits_finite":
                initial_forward["logits_finite"],
            "final_logits_finite": final_forward["logits_finite"],
            "initial_causal_prefix_max_logit_delta":
                initial_forward["causal_prefix_max_logit_delta"],
            "final_causal_prefix_max_logit_delta":
                final_forward["causal_prefix_max_logit_delta"],
            "initial_suffix_effect_max_logit_delta":
                initial_forward["suffix_effect_max_logit_delta"],
            "final_suffix_effect_max_logit_delta":
                final_forward["suffix_effect_max_logit_delta"],
        },
        "evaluation": {
            "initial_train_loss": initial_train_loss,
            "initial_train_accuracy": initial_train_accuracy,
            "initial_holdout_loss": initial_holdout_loss,
            "initial_holdout_accuracy": initial_holdout_accuracy,
            "final_train_loss": final_train_loss,
            "final_train_accuracy": final_train_accuracy,
            "validation_loss": validation_loss,
            "validation_accuracy": validation_accuracy,
            "holdout_loss": holdout_loss,
            "holdout_accuracy": holdout_accuracy,
            "mutation_loss": mutation_loss,
            "mutation_accuracy": mutation_accuracy,
            "conservation_accuracy": subset_accuracy(conservation_ids),
            "order_sensitive_accuracy": subset_accuracy(order_sensitive_ids),
            "engine_coupled_primitive_accuracy":
                engine_coupled["primitive_accuracy"],
            "engine_coupled_holdout_accuracy":
                engine_coupled["accuracy"],
            "validation_results": validation_results,
            "holdout_results": holdout_results,
            "mutation_results": mutation_results,
            "engine_coupled_results": engine_coupled["results"],
            "engine_coupled_primitive_results":
                engine_coupled["primitive_results"],
        },
        "durability": {
            "checkpoint": checkpoint.name,
            "checkpoint_sha256": checkpoint_hash,
            "checkpoint_strict_load": True,
            "checkpoint_weight_tensor_count":
                checkpoint_reload_weights["tensor_count"],
            "checkpoint_reload_weights_exact":
                checkpoint_reload_weights["exact"],
            "checkpoint_reload_max_logit_delta": checkpoint_reload_delta,
            "checkpoint_reload_max_weight_delta":
                checkpoint_reload_weights["max_delta"],
            "repeated_inference_max_logit_delta":
                repeated_inference_delta,
            "same_seed_replay_seed": args.seed,
            "same_seed_replay_completed_steps":
                len(replay_losses),
            "same_seed_replay_loss_steps_compared":
                len(losses)
                if len(losses) == len(replay_losses)
                else 0,
            "same_seed_replay_weight_tensor_count":
                same_seed_replay_weights["tensor_count"],
            "same_seed_replay_weights_exact":
                same_seed_replay_weights["exact"],
            "same_seed_replay_checkpoint":
                replay_checkpoint.name,
            "same_seed_replay_checkpoint_sha256":
                replay_checkpoint_hash,
            "same_seed_replay_max_loss_delta":
                same_seed_replay_loss_delta,
            "same_seed_replay_max_logit_delta":
                same_seed_replay_logit_delta,
            "same_seed_replay_max_weight_delta":
                same_seed_replay_weights["max_delta"],
            "same_seed_bitwise_replay_exact":
                same_seed_bitwise_replay_exact,
        },
        "seed_replay": {
            "behavioral_replay_verified":
                same_seed_behavioral_replay,
            "initial_train_loss": replay_initial_train_loss,
            "initial_holdout_loss": replay_initial_holdout_loss,
            "final_train_loss": replay_final_train_loss,
            "final_train_accuracy": replay_final_train_accuracy,
            "validation_loss": replay_validation_loss,
            "validation_accuracy": replay_validation_accuracy,
            "holdout_loss": replay_holdout_loss,
            "holdout_accuracy": replay_holdout_accuracy,
            "mutation_loss": replay_mutation_loss,
            "mutation_accuracy": replay_mutation_accuracy,
            "engine_coupled_primitive_accuracy":
                replay_engine_coupled["primitive_accuracy"],
            "engine_coupled_holdout_accuracy":
                replay_engine_coupled["accuracy"],
            "validation_results": replay_validation_results,
            "holdout_results": replay_holdout_results,
            "mutation_results": replay_mutation_results,
            "engine_coupled_results":
                replay_engine_coupled["results"],
            "engine_coupled_primitive_results":
                replay_engine_coupled["primitive_results"],
        },
        "gates": {
            "mechanics_outcome":
                "GROUNDED" if mechanics_grounded else "ABSTAIN",
            "compositional_outcome":
                "GROUNDED" if compositional_grounded else "ABSTAIN",
            "functional_english_authorized": False,
            "product_promotion_authorized": False,
        },
        "next_action": (
            "bind_prime_domain_shadow_canary"
            if outcome == "GROUNDED"
            else (
                "retain_engine_composition_and_test_trace_curriculum"
                if mechanics_grounded
                and engine_coupled["primitive_accuracy"] >= 0.95
                and engine_coupled["accuracy"] >= 0.95
                else "diagnose_native_mechanics_or_primitive_failure"
            )
        ),
    }
    report_path = args.output / "prime-native-mechanics-canary.json"
    report_path.write_text(
        json.dumps(
            report,
            allow_nan=False,
            indent=2,
            sort_keys=True,
        ) + "\n",
        encoding="utf-8",
    )
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--language-manifest", type=Path, required=True)
    parser.add_argument("--steps", type=int, default=800)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--learning-rate", type=float, default=3e-4)
    parser.add_argument("--weight-decay", type=float, default=0.01)
    parser.add_argument("--seed", type=int, default=1729)
    parser.add_argument("--max-seconds", type=float, default=900)
    parser.add_argument("--minimum-accuracy", type=float, default=0.80)
    parser.add_argument(
        "--minimum-mutation-accuracy",
        type=float,
        default=0.80,
    )
    args = parser.parse_args()
    report = run(args)
    print(
        json.dumps(
            {
                "outcome": report["outcome"],
                "mechanics_outcome":
                    report["gates"]["mechanics_outcome"],
                "compositional_outcome":
                    report["gates"]["compositional_outcome"],
                "train_accuracy":
                    report["evaluation"]["final_train_accuracy"],
                "holdout_accuracy":
                    report["evaluation"]["holdout_accuracy"],
                "mutation_accuracy":
                    report["evaluation"]["mutation_accuracy"],
                "engine_coupled_holdout_accuracy":
                    report["evaluation"][
                        "engine_coupled_holdout_accuracy"
                    ],
                "tokens_per_second":
                    report["training"]["tokens_per_second"],
                "peak_memory_bytes":
                    report["training"]["peak_memory_bytes"],
                "same_seed_behavioral_replay_verified":
                    report["seed_replay"][
                        "behavioral_replay_verified"
                    ],
                "same_seed_bitwise_replay_exact":
                    report["durability"][
                        "same_seed_bitwise_replay_exact"
                    ],
            },
            indent=2,
            sort_keys=True,
        )
    )
    return 0 if report["outcome"] == "GROUNDED" else 2


if __name__ == "__main__":
    raise SystemExit(main())
