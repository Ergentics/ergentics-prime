#![forbid(unsafe_code)]

//! Independent, deny-only verifier for CapabilityFlowClosure v1 receipts.
//!
//! Production protocol: zero arguments, one bounded `ERGRHV01` frame on stdin,
//! mandatory EOF, no output. Exit 0 means that the canonical CBOR, three-leaf
//! Merkle commitment, declared access/evidence coverage, result projection, and
//! Riemann deny-only predicate agree. Every failure is collapsed to exit 70.
//! This executable is not a mathematical proof checker, does not establish
//! runtime trace completeness, and does not validate non-Riemann finding semantics.

use std::collections::{BTreeMap, BTreeSet};
use std::io::{self, Read};
use std::process::ExitCode;

const MAGIC: &[u8; 8] = b"ERGRHV01";
const VERSION: u16 = 1;
const HEADER_BYTES: usize = 84;
const MAX_BYTES: usize = 1_048_576;
const MAX_DEPTH: usize = 16;
const MAX_COLLECTION: usize = 256;
const MAX_NODES: usize = 8_192;
const MAX_OBJECTS: usize = 128;
const MAX_EXECUTIONS: usize = 32;

const REPORT_SCHEMA: &str = "ergentics.capability-flow-closure.report.v1";
const SCENARIO_SCHEMA: &str = "ergentics.capability-flow-closure.scenario.v1";
const POLICY_ID: &str = "5bf9bcfdad8afb2fe60aa35d4a44c9a1f195512b8665beb796f98904d951addf";
const POLICY_GENERATION: u64 = 1;
const RH: u64 = 1;
const ROLE_THEOREM: u64 = 14;
const DISPOSITION_VERIFIED: u64 = 2;
const OP_CERTIFY_THEOREM: u64 = 18;
const TERMINAL_COMPLETED: u64 = 1;
const TERMINAL_BLOCKED: u64 = 2;
const UNVERIFIED: &str = "UNVERIFIED_THEOREM_CLAIM";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct Reject;

type Checked<T> = Result<T, Reject>;

fn main() -> ExitCode {
    std::panic::set_hook(Box::new(|_| {}));
    let accepted = std::panic::catch_unwind(|| {
        std::env::args_os().count() == 1 && verify_reader(io::stdin().lock()).is_ok()
    }).unwrap_or(false);
    if accepted { ExitCode::SUCCESS } else { ExitCode::from(70) }
}

fn verify_reader<R: Read>(mut reader: R) -> Checked<()> {
    let mut header = [0u8; HEADER_BYTES];
    reader.read_exact(&mut header).map_err(|_| Reject)?;
    if &header[..8] != MAGIC { return Err(Reject); }
    if u16::from_be_bytes([header[8], header[9]]) != VERSION { return Err(Reject); }
    if u16::from_be_bytes([header[10], header[11]]) != 0 { return Err(Reject); }

    let scenario_len = u32::from_be_bytes(header[12..16].try_into().map_err(|_| Reject)?) as usize;
    let result_len = u32::from_be_bytes(header[16..20].try_into().map_err(|_| Reject)?) as usize;
    if scenario_len == 0 || result_len == 0 || scenario_len > MAX_BYTES || result_len > MAX_BYTES {
        return Err(Reject);
    }
    let expected_root = decode_lower_hex_32(&header[20..84])?;
    admitted_merkle_bytes(scenario_len, result_len)?;

    let mut scenario = vec![0u8; scenario_len];
    let mut result = vec![0u8; result_len];
    reader.read_exact(&mut scenario).map_err(|_| Reject)?;
    reader.read_exact(&mut result).map_err(|_| Reject)?;
    let mut trailing = [0u8; 1];
    if reader.read(&mut trailing).map_err(|_| Reject)? != 0 { return Err(Reject); }
    verify_receipt(&scenario, &result, expected_root)
}

fn admitted_merkle_bytes(scenario: usize, result: usize) -> Checked<()> {
    let labels = b"result".len() + b"scenario".len() + b"schema".len();
    let total = labels.checked_add(REPORT_SCHEMA.len()).and_then(|v| v.checked_add(scenario))
        .and_then(|v| v.checked_add(result)).ok_or(Reject)?;
    if total > MAX_BYTES { Err(Reject) } else { Ok(()) }
}

fn decode_lower_hex_32(bytes: &[u8]) -> Checked<[u8; 32]> {
    if bytes.len() != 64 { return Err(Reject); }
    let mut result = [0u8; 32];
    for index in 0..32 {
        let high = hex_nibble(bytes[index * 2])?;
        let low = hex_nibble(bytes[index * 2 + 1])?;
        result[index] = (high << 4) | low;
    }
    Ok(result)
}

fn hex_nibble(byte: u8) -> Checked<u8> {
    match byte {
        b'0'..=b'9' => Ok(byte - b'0'),
        b'a'..=b'f' => Ok(byte - b'a' + 10),
        _ => Err(Reject),
    }
}

fn verify_receipt(scenario_bytes: &[u8], result_bytes: &[u8], expected_root: [u8; 32]) -> Checked<()> {
    if scenario_bytes.is_empty() || result_bytes.is_empty() ||
       scenario_bytes.len() > MAX_BYTES || result_bytes.len() > MAX_BYTES {
        return Err(Reject);
    }
    admitted_merkle_bytes(scenario_bytes.len(), result_bytes.len())?;
    let scenario_value = decode_canonical(scenario_bytes)?;
    let result_value = decode_canonical(result_bytes)?;
    let root = receipt_root(scenario_bytes, result_bytes)?;
    if !constant_time_equal(&root, &expected_root) { return Err(Reject); }

    let scenario = parse_scenario(&scenario_value)?;
    let result = parse_result(&result_value)?;
    verify_rh(&scenario, &result)
}

fn receipt_root(scenario: &[u8], result: &[u8]) -> Checked<[u8; 32]> {
    admitted_merkle_bytes(scenario.len(), result.len())?;
    let mut leaves = vec![
        (b"result".as_slice(), result),
        (b"scenario".as_slice(), scenario),
        (b"schema".as_slice(), REPORT_SCHEMA.as_bytes()),
    ];
    leaves.sort_by(|left, right| left.0.cmp(right.0));
    let mut level: Vec<[u8; 32]> = leaves.into_iter().map(|(label, payload)| leaf_hash(label, payload)).collect();
    while level.len() > 1 {
        let mut next = Vec::with_capacity((level.len() + 1) / 2);
        for pair in level.chunks(2) {
            let mut frame = Vec::with_capacity(if pair.len() == 2 { 65 } else { 33 });
            frame.push(if pair.len() == 2 { 0x01 } else { 0x03 });
            frame.extend_from_slice(pair.first().ok_or(Reject)?);
            if pair.len() == 2 { frame.extend_from_slice(&pair[1]); }
            next.push(sha256(&frame));
        }
        level = next;
    }
    let mut frame = Vec::with_capacity(41);
    frame.push(0x02);
    frame.extend_from_slice(&3u64.to_be_bytes());
    frame.extend_from_slice(level.first().ok_or(Reject)?);
    Ok(sha256(&frame))
}

fn leaf_hash(label: &[u8], payload: &[u8]) -> [u8; 32] {
    let mut frame = Vec::with_capacity(1 + 4 + label.len() + 8 + payload.len());
    frame.push(0x00);
    frame.extend_from_slice(&(label.len() as u32).to_be_bytes());
    frame.extend_from_slice(label);
    frame.extend_from_slice(&(payload.len() as u64).to_be_bytes());
    frame.extend_from_slice(payload);
    sha256(&frame)
}

fn constant_time_equal(left: &[u8; 32], right: &[u8; 32]) -> bool {
    left.iter().zip(right.iter()).fold(0u8, |difference, (a, b)| difference | (a ^ b)) == 0
}

#[derive(Clone, Debug, Eq, PartialEq)]
enum Value {
    Unsigned(u64),
    Bytes(Vec<u8>),
    Text(String),
    Array(Vec<Value>),
    Map(BTreeMap<String, Value>),
    Bool(bool),
}

fn decode_canonical(bytes: &[u8]) -> Checked<Value> {
    if bytes.is_empty() || bytes.len() > MAX_BYTES { return Err(Reject); }
    let mut decoder = Decoder { bytes, offset: 0, nodes: 0 };
    let value = decoder.take(0)?;
    if decoder.offset != bytes.len() { return Err(Reject); }
    if encode_canonical(&value)? != bytes { return Err(Reject); }
    Ok(value)
}

struct Decoder<'a> {
    bytes: &'a [u8],
    offset: usize,
    nodes: usize,
}

impl<'a> Decoder<'a> {
    fn take(&mut self, depth: usize) -> Checked<Value> {
        if depth > MAX_DEPTH || self.nodes >= MAX_NODES || self.offset >= self.bytes.len() {
            return Err(Reject);
        }
        self.nodes += 1;
        let initial = self.bytes[self.offset];
        self.offset += 1;
        if initial == 0xf4 { return Ok(Value::Bool(false)); }
        if initial == 0xf5 { return Ok(Value::Bool(true)); }
        let major = initial >> 5;
        if major > 5 || major == 1 { return Err(Reject); }
        let count = self.argument(initial & 31)?;
        match major {
            0 => Ok(Value::Unsigned(count)),
            2 | 3 => {
                let length = usize::try_from(count).map_err(|_| Reject)?;
                let end = self.offset.checked_add(length).ok_or(Reject)?;
                if end > self.bytes.len() { return Err(Reject); }
                let raw = &self.bytes[self.offset..end];
                self.offset = end;
                if major == 2 {
                    Ok(Value::Bytes(raw.to_vec()))
                } else {
                    let text = std::str::from_utf8(raw).map_err(|_| Reject)?;
                    Ok(Value::Text(text.to_owned()))
                }
            }
            4 => {
                let length = collection_length(count)?;
                let mut values = Vec::with_capacity(length);
                for _ in 0..length { values.push(self.take(depth + 1)?); }
                Ok(Value::Array(values))
            }
            5 => {
                let length = collection_length(count)?;
                let mut values = BTreeMap::new();
                let mut previous: Option<Vec<u8>> = None;
                for _ in 0..length {
                    let key_start = self.offset;
                    let key = match self.take(depth + 1)? {
                        Value::Text(value) if value.is_ascii() => value,
                        _ => return Err(Reject),
                    };
                    let encoded_key = self.bytes[key_start..self.offset].to_vec();
                    if previous.as_ref().is_some_and(|value| value >= &encoded_key) { return Err(Reject); }
                    previous = Some(encoded_key);
                    let value = self.take(depth + 1)?;
                    if values.insert(key, value).is_some() { return Err(Reject); }
                }
                Ok(Value::Map(values))
            }
            _ => Err(Reject),
        }
    }

    fn argument(&mut self, additional: u8) -> Checked<u64> {
        if additional < 24 { return Ok(additional as u64); }
        let (width, minimum) = match additional {
            24 => (1usize, 24u64),
            25 => (2, 256),
            26 => (4, 65_536),
            27 => (8, 4_294_967_296),
            _ => return Err(Reject),
        };
        let end = self.offset.checked_add(width).ok_or(Reject)?;
        if end > self.bytes.len() { return Err(Reject); }
        let mut value = 0u64;
        for byte in &self.bytes[self.offset..end] { value = (value << 8) | (*byte as u64); }
        self.offset = end;
        if value < minimum { return Err(Reject); }
        Ok(value)
    }
}

fn collection_length(value: u64) -> Checked<usize> {
    let value = usize::try_from(value).map_err(|_| Reject)?;
    if value > MAX_COLLECTION { Err(Reject) } else { Ok(value) }
}

fn encode_canonical(value: &Value) -> Checked<Vec<u8>> {
    let mut output = Vec::new();
    let mut nodes = 0usize;
    put_value(value, 0, &mut nodes, &mut output)?;
    Ok(output)
}

fn put_value(value: &Value, depth: usize, nodes: &mut usize, output: &mut Vec<u8>) -> Checked<()> {
    if depth > MAX_DEPTH || *nodes >= MAX_NODES { return Err(Reject); }
    *nodes += 1;
    match value {
        Value::Unsigned(number) => put_argument(0, *number, output)?,
        Value::Bool(flag) => push_bounded(output, if *flag { 0xf5 } else { 0xf4 })?,
        Value::Bytes(bytes) => {
            put_argument(2, bytes.len() as u64, output)?;
            extend_bounded(output, bytes)?;
        }
        Value::Text(text) => {
            put_argument(3, text.len() as u64, output)?;
            extend_bounded(output, text.as_bytes())?;
        }
        Value::Array(values) => {
            if values.len() > MAX_COLLECTION { return Err(Reject); }
            put_argument(4, values.len() as u64, output)?;
            for item in values { put_value(item, depth + 1, nodes, output)?; }
        }
        Value::Map(values) => {
            if values.len() > MAX_COLLECTION { return Err(Reject); }
            put_argument(5, values.len() as u64, output)?;
            let mut entries: Vec<(Vec<u8>, &Value)> = Vec::with_capacity(values.len());
            for (key, item) in values {
                if !key.is_ascii() { return Err(Reject); }
                let mut encoded_key = Vec::new();
                put_argument(3, key.len() as u64, &mut encoded_key)?;
                extend_bounded(&mut encoded_key, key.as_bytes())?;
                entries.push((encoded_key, item));
            }
            entries.sort_by(|left, right| left.0.cmp(&right.0));
            for (key, item) in entries {
                if *nodes >= MAX_NODES { return Err(Reject); }
                *nodes += 1;
                extend_bounded(output, &key)?;
                put_value(item, depth + 1, nodes, output)?;
            }
        }
    }
    Ok(())
}

fn put_argument(major: u8, value: u64, output: &mut Vec<u8>) -> Checked<()> {
    if value < 24 {
        push_bounded(output, (major << 5) | value as u8)
    } else if value <= u8::MAX as u64 {
        extend_bounded(output, &[(major << 5) | 24, value as u8])
    } else if value <= u16::MAX as u64 {
        push_bounded(output, (major << 5) | 25)?;
        extend_bounded(output, &(value as u16).to_be_bytes())
    } else if value <= u32::MAX as u64 {
        push_bounded(output, (major << 5) | 26)?;
        extend_bounded(output, &(value as u32).to_be_bytes())
    } else {
        push_bounded(output, (major << 5) | 27)?;
        extend_bounded(output, &value.to_be_bytes())
    }
}

fn push_bounded(output: &mut Vec<u8>, byte: u8) -> Checked<()> {
    if output.len() >= MAX_BYTES { return Err(Reject); }
    output.push(byte);
    Ok(())
}

fn extend_bounded(output: &mut Vec<u8>, bytes: &[u8]) -> Checked<()> {
    if bytes.len() > MAX_BYTES.saturating_sub(output.len()) { return Err(Reject); }
    output.extend_from_slice(bytes);
    Ok(())
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
struct TheoremState {
    theorem: u64,
    disposition: u64,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct ObjectView {
    owner: Option<u32>,
    role: u64,
    theorem: Option<TheoremState>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct Certification {
    id: u32,
    execution: u32,
    object: u32,
    capability: u32,
    performed: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct AccessRecord {
    id: u32,
    execution: u32,
    object: u32,
    operation: u64,
    method: u64,
    peer: u32,
    capability: u32,
    outcome: u64,
    phase: u64,
}

#[derive(Debug)]
struct ExecutionView {
    purpose: u32,
    capabilities: BTreeSet<u32>,
}

#[derive(Debug)]
struct ScenarioView {
    before: BTreeMap<u32, ObjectView>,
    after: BTreeMap<u32, ObjectView>,
    certifications: Vec<Certification>,
    transition_id: u32,
    execution_id: u32,
    formal_claim: Option<u32>,
    goal_satisfied: bool,
    boundary_reached: bool,
    terminal: u64,
}

fn parse_scenario(value: &Value) -> Checked<ScenarioView> {
    let root = map_value(value)?;
    require_keys(root, &["schema", "roots", "before_objects", "after_objects", "grants",
        "capabilities", "executions", "transition", "accesses", "evidence", "verifier"])?;
    if text_value(get(root, "schema")?)? != SCENARIO_SCHEMA { return Err(Reject); }
    parse_roots(array_value(get(root, "roots")?)?)?;
    let before = parse_objects(array_value(get(root, "before_objects")?)?)?;
    let after = parse_objects(array_value(get(root, "after_objects")?)?)?;
    let executions = parse_executions(array_value(get(root, "executions")?)?)?;
    let grants = parse_grants(array_value(get(root, "grants")?)?, &after, &executions)?;
    let capabilities = parse_capabilities(array_value(get(root, "capabilities")?)?, &grants)?;
    for execution in executions.values() {
        if execution.capabilities.iter().any(|id| !capabilities.contains_key(id)) {
            return Err(Reject);
        }
    }
    let evidence_values = array_value(get(root, "evidence")?)?;
    let verifier = required_id(get(root, "verifier")?)?;
    if executions.contains_key(&verifier) { return Err(Reject); }
    for object in before.values().chain(after.values()) {
        if object.owner.is_some_and(|owner| !executions.contains_key(&owner)) { return Err(Reject); }
    }

    let transition = map_value(get(root, "transition")?)?;
    require_keys(transition, &["id", "execution", "purpose", "goal", "before_caps", "after_caps",
        "policy_before", "policy_after", "generation_before", "generation_after", "goal_satisfied",
        "boundary_reached", "terminal", "chi_before", "chi_after", "resources"])?;
    let transition_id = required_id(get(transition, "id")?)?;
    let execution_id = required_id(get(transition, "execution")?)?;
    let purpose = required_id(get(transition, "purpose")?)?;
    let assessed = executions.get(&execution_id).ok_or(Reject)?;
    if assessed.purpose != purpose { return Err(Reject); }
    let before_caps: BTreeSet<u32> = parse_sorted_ids(
        array_value(get(transition, "before_caps")?)?)?.into_iter().collect();
    let after_caps: BTreeSet<u32> = parse_sorted_ids(
        array_value(get(transition, "after_caps")?)?)?.into_iter().collect();
    if before_caps.iter().chain(after_caps.iter()).any(|id| !capabilities.contains_key(id)) ||
       assessed.capabilities != after_caps {
        return Err(Reject);
    }
    if text_value(get(transition, "policy_before")?)? != POLICY_ID ||
       text_value(get(transition, "policy_after")?)? != POLICY_ID ||
       unsigned(get(transition, "generation_before")?)? != POLICY_GENERATION ||
       unsigned(get(transition, "generation_after")?)? != POLICY_GENERATION {
        return Err(Reject);
    }
    let goal_satisfied = bool_value(get(transition, "goal_satisfied")?)?;
    let boundary_reached = bool_value(get(transition, "boundary_reached")?)?;
    let terminal = unsigned(get(transition, "terminal")?)?;
    if !(1..=3).contains(&terminal) { return Err(Reject); }
    let chi_before = unsigned(get(transition, "chi_before")?)?;
    let chi_after = unsigned(get(transition, "chi_after")?)?;
    if chi_before != chi_after { return Err(Reject); }
    parse_resources(array_value(get(transition, "resources")?)?)?;
    let formal_claim = parse_goal(array_value(get(transition, "goal")?)?, &after)?;

    let (accesses, certifications) = parse_accesses(array_value(get(root, "accesses")?)?,
        &after, &executions, &capabilities)?;
    parse_evidence(evidence_values, &accesses, verifier)?;
    Ok(ScenarioView { before, after, certifications, transition_id, execution_id,
        formal_claim, goal_satisfied, boundary_reached, terminal })
}

fn parse_roots(values: &[Value]) -> Checked<()> {
    if values.len() != 1 { return Err(Reject); }
    let root = array_value(&values[0])?;
    if root.len() != 3 || required_id(&root[0])? != 1 || text_value(&root[1])? != POLICY_ID ||
       unsigned(&root[2])? != POLICY_GENERATION { return Err(Reject); }
    Ok(())
}

fn parse_objects(values: &[Value]) -> Checked<BTreeMap<u32, ObjectView>> {
    if values.len() > MAX_OBJECTS { return Err(Reject); }
    let mut result = BTreeMap::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 11 { return Err(Reject); }
        let id = required_id(&fields[0])?;
        let owner = optional_id(&fields[1])?;
        let role = unsigned(&fields[2])?;
        if !(1..=14).contains(&role) { return Err(Reject); }
        for field in &fields[3..8] { bool_value(field)?; }
        if unsigned(&fields[8])? == 0 { return Err(Reject); }
        let channel = unsigned(&fields[9])?;
        if !(1..=11).contains(&channel) { return Err(Reject); }
        let theorem_values = array_value(&fields[10])?;
        let theorem = if role == ROLE_THEOREM {
            if theorem_values.len() != 2 { return Err(Reject); }
            let theorem = unsigned(&theorem_values[0])?;
            let disposition = unsigned(&theorem_values[1])?;
            if theorem != RH || !(1..=2).contains(&disposition) { return Err(Reject); }
            Some(TheoremState { theorem, disposition })
        } else {
            if !theorem_values.is_empty() { return Err(Reject); }
            None
        };
        if result.insert(id, ObjectView { owner, role, theorem }).is_some() { return Err(Reject); }
    }
    Ok(result)
}

fn parse_executions(values: &[Value]) -> Checked<BTreeMap<u32, ExecutionView>> {
    if values.is_empty() || values.len() > MAX_EXECUTIONS { return Err(Reject); }
    let mut result = BTreeMap::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 4 { return Err(Reject); }
        let id = required_id(&fields[0])?;
        let generation = unsigned(&fields[1])?;
        if generation == 0 { return Err(Reject); }
        let purpose = required_id(&fields[2])?;
        let capabilities = parse_sorted_ids(array_value(&fields[3])?)?.into_iter().collect();
        if result.insert(id, ExecutionView { purpose, capabilities }).is_some() {
            return Err(Reject);
        }
    }
    Ok(result)
}

fn parse_grants(values: &[Value], after: &BTreeMap<u32, ObjectView>,
                executions: &BTreeMap<u32, ExecutionView>) -> Checked<BTreeSet<u32>> {
    let mut result = BTreeSet::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 14 { return Err(Reject); }
        let id = required_id(&fields[0])?;
        if !result.insert(id) { return Err(Reject); }
        let issuer = array_value(&fields[1])?;
        if issuer.len() != 2 { return Err(Reject); }
        let issuer_kind = unsigned(&issuer[0])?;
        let issuer_id = required_id(&issuer[1])?;
        if (issuer_kind == 0 && issuer_id != 1) ||
           (issuer_kind == 1 && !executions.contains_key(&issuer_id)) || issuer_kind > 1 {
            return Err(Reject);
        }
        let subject = required_id(&fields[2])?;
        if !executions.contains_key(&subject) { return Err(Reject); }
        let object = required_id(&fields[3])?;
        if !after.contains_key(&object) { return Err(Reject); }
        if !(1..=18).contains(&unsigned(&fields[4])?) ||
           !(1..=5).contains(&unsigned(&fields[5])?) {
            return Err(Reject);
        }
        required_id(&fields[6])?;
        let peer = optional_id(&fields[7])?;
        if peer.is_some_and(|value| !executions.contains_key(&value)) { return Err(Reject); }
        let valid_from = unsigned(&fields[8])?;
        let valid_through = unsigned(&fields[9])?;
        if valid_from == 0 || valid_from > valid_through { return Err(Reject); }
        bool_value(&fields[10])?;
        bool_value(&fields[11])?;
        bool_value(&fields[12])?;
        optional_id(&fields[13])?;
    }
    Ok(result)
}

fn parse_capabilities(values: &[Value], grants: &BTreeSet<u32>)
                      -> Checked<BTreeMap<u32, u32>> {
    let mut result = BTreeMap::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 2 { return Err(Reject); }
        let id = required_id(&fields[0])?;
        let grant = required_id(&fields[1])?;
        if !grants.contains(&grant) || result.insert(id, grant).is_some() {
            return Err(Reject);
        }
    }
    Ok(result)
}

fn parse_sorted_ids(values: &[Value]) -> Checked<Vec<u32>> {
    let mut result = Vec::with_capacity(values.len());
    let mut previous = 0u32;
    for value in values {
        let id = required_id(value)?;
        if id <= previous { return Err(Reject); }
        previous = id;
        result.push(id);
    }
    Ok(result)
}

fn parse_resources(values: &[Value]) -> Checked<()> {
    if values.len() != 9 { return Err(Reject); }
    for value in values { unsigned(value)?; }
    Ok(())
}

fn parse_goal(values: &[Value], after: &BTreeMap<u32, ObjectView>) -> Checked<Option<u32>> {
    if values.len() == 2 && unsigned(&values[0])? == 0 {
        let id = required_id(&values[1])?;
        let object = after.get(&id).ok_or(Reject)?;
        if object.role == ROLE_THEOREM { return Err(Reject); }
        Ok(None)
    } else if values.len() == 3 && unsigned(&values[0])? == 1 {
        if unsigned(&values[1])? != RH { return Err(Reject); }
        let id = required_id(&values[2])?;
        let object = after.get(&id).ok_or(Reject)?;
        if object.role != ROLE_THEOREM || object.theorem.map(|state| state.theorem) != Some(RH) {
            return Err(Reject);
        }
        Ok(Some(id))
    } else {
        Err(Reject)
    }
}

fn parse_accesses(values: &[Value], after: &BTreeMap<u32, ObjectView>,
                  executions: &BTreeMap<u32, ExecutionView>,
                  capabilities: &BTreeMap<u32, u32>)
                  -> Checked<(BTreeMap<u32, AccessRecord>, Vec<Certification>)> {
    let mut accesses = BTreeMap::new();
    let mut certifications = Vec::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 9 { return Err(Reject); }
        let id = required_id(&fields[0])?;
        let execution = required_id(&fields[1])?;
        if !executions.contains_key(&execution) { return Err(Reject); }
        let object = required_id(&fields[2])?;
        if !after.contains_key(&object) { return Err(Reject); }
        let operation = unsigned(&fields[3])?;
        if !(1..=18).contains(&operation) { return Err(Reject); }
        let method = unsigned(&fields[4])?;
        if !(1..=5).contains(&method) { return Err(Reject); }
        let peer = optional_id(&fields[5])?.unwrap_or(0);
        if peer != 0 && !executions.contains_key(&peer) { return Err(Reject); }
        let capability = optional_id(&fields[6])?.unwrap_or(0);
        if capability != 0 && !capabilities.contains_key(&capability) { return Err(Reject); }
        let outcome = unsigned(&fields[7])?;
        if outcome > 1 { return Err(Reject); }
        let phase = unsigned(&fields[8])?;
        if !(1..=2).contains(&phase) { return Err(Reject); }
        let record = AccessRecord { id, execution, object, operation, method, peer,
            capability, outcome, phase };
        if accesses.insert(id, record).is_some() { return Err(Reject); }
        if operation == OP_CERTIFY_THEOREM {
            certifications.push(Certification { id, execution, object, capability,
                performed: outcome == 1 });
        }
    }
    Ok((accesses, certifications))
}

// This proves only declared trace coverage inside the committed scenario. It
// does not prove that runtime activity outside the declared access list is
// complete or absent.
fn parse_evidence(values: &[Value], accesses: &BTreeMap<u32, AccessRecord>, verifier: u32)
                  -> Checked<()> {
    if values.len() != accesses.len() { return Err(Reject); }
    let mut evidence_ids = BTreeSet::new();
    let mut covered_accesses = BTreeSet::new();
    for (index, value) in values.iter().enumerate() {
        let fields = array_value(value)?;
        if fields.len() != 6 { return Err(Reject); }
        let evidence_id = required_id(&fields[0])?;
        if !evidence_ids.insert(evidence_id) { return Err(Reject); }
        let access_id = required_id(&fields[1])?;
        if !covered_accesses.insert(access_id) { return Err(Reject); }
        if unsigned(&fields[2])? != index as u64 || required_id(&fields[3])? != verifier {
            return Err(Reject);
        }
        let digest = match &fields[4] {
            Value::Bytes(bytes) if bytes.len() == 32 => bytes,
            _ => return Err(Reject),
        };
        if bool_value(&fields[5])? { return Err(Reject); }
        let access = accesses.get(&access_id).ok_or(Reject)?;
        if !constant_time_equal_slice(digest, &access_evidence_digest(access)?) { return Err(Reject); }
    }
    if covered_accesses.len() != accesses.len() ||
       accesses.keys().any(|id| !covered_accesses.contains(id)) {
        return Err(Reject);
    }
    Ok(())
}

fn access_evidence_digest(access: &AccessRecord) -> Checked<[u8; 32]> {
    let frame = Value::Map([
        ("schema".to_owned(), Value::Text(
            "ergentics.capability-flow-closure.access-evidence.v1".to_owned())),
        ("id".to_owned(), Value::Unsigned(access.id as u64)),
        ("execution".to_owned(), Value::Unsigned(access.execution as u64)),
        ("object".to_owned(), Value::Unsigned(access.object as u64)),
        ("operation".to_owned(), Value::Unsigned(access.operation)),
        ("method".to_owned(), Value::Unsigned(access.method)),
        ("peer".to_owned(), Value::Unsigned(access.peer as u64)),
        ("capability".to_owned(), Value::Unsigned(access.capability as u64)),
        ("outcome".to_owned(), Value::Unsigned(access.outcome)),
        ("phase".to_owned(), Value::Unsigned(access.phase)),
    ].into_iter().collect());
    Ok(sha256(&encode_canonical(&frame)?))
}

fn constant_time_equal_slice(left: &[u8], right: &[u8; 32]) -> bool {
    left.len() == 32 && left.iter().zip(right.iter())
        .fold(0u8, |difference, (a, b)| difference | (a ^ b)) == 0
}

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
struct Finding {
    code: String,
    execution: u32,
    object: u32,
    capability: u32,
    transition: u32,
}

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
struct Tripwire {
    kind: String,
    access: u32,
    execution: u32,
    object: u32,
    reachability_delta: bool,
}

#[derive(Debug)]
struct ResultView {
    status: String,
    findings: BTreeSet<Finding>,
    tripwires: BTreeSet<Tripwire>,
    eligible: bool,
}

fn parse_result(value: &Value) -> Checked<ResultView> {
    let root = map_value(value)?;
    require_keys(root, &["schema", "status", "findings", "channels", "tripwires",
        "commit_candidate_eligible", "change_index_delta"])?;
    if text_value(get(root, "schema")?)? != REPORT_SCHEMA { return Err(Reject); }
    let status = text_value(get(root, "status")?)?.to_owned();
    if !["DECLARED_GRAPH_CLOSED", "DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION",
          "REJECTED_CLOSURE"].contains(&status.as_str()) { return Err(Reject); }

    let mut findings = BTreeSet::new();
    for value in array_value(get(root, "findings")?)? {
        let fields = array_value(value)?;
        if fields.len() != 5 { return Err(Reject); }
        let code = text_value(&fields[0])?;
        if !known_finding(code) { return Err(Reject); }
        let finding = Finding { code: code.to_owned(), execution: optional_id(&fields[1])?.unwrap_or(0),
            object: optional_id(&fields[2])?.unwrap_or(0), capability: optional_id(&fields[3])?.unwrap_or(0),
            transition: optional_id(&fields[4])?.unwrap_or(0) };
        if !findings.insert(finding) { return Err(Reject); }
    }

    parse_channels(array_value(get(root, "channels")?)?)?;
    let mut tripwires = BTreeSet::new();
    for value in array_value(get(root, "tripwires")?)? {
        let fields = array_value(value)?;
        if fields.len() != 5 { return Err(Reject); }
        let kind = text_value(&fields[0])?;
        if !known_tripwire(kind) { return Err(Reject); }
        let tripwire = Tripwire { kind: kind.to_owned(), access: optional_id(&fields[1])?.unwrap_or(0),
            execution: required_id(&fields[2])?, object: optional_id(&fields[3])?.unwrap_or(0),
            reachability_delta: bool_value(&fields[4])? };
        if !tripwires.insert(tripwire) { return Err(Reject); }
    }
    let eligible = bool_value(get(root, "commit_candidate_eligible")?)?;
    if unsigned(get(root, "change_index_delta")?)? != 0 { return Err(Reject); }
    Ok(ResultView { status, findings, tripwires, eligible })
}

fn parse_channels(values: &[Value]) -> Checked<()> {
    let mut seen = BTreeSet::new();
    for value in values {
        let fields = array_value(value)?;
        if fields.len() != 7 { return Err(Reject); }
        let source = required_id(&fields[0])?;
        let sink = required_id(&fields[1])?;
        let object = required_id(&fields[2])?;
        let class = unsigned(&fields[3])?;
        if !(1..=11).contains(&class) { return Err(Reject); }
        let bits = unsigned(&fields[4])?;
        let survives = bool_value(&fields[5])?;
        let authorized = bool_value(&fields[6])?;
        if !seen.insert((source, sink, object, class, bits, survives, authorized)) { return Err(Reject); }
    }
    Ok(())
}

fn verify_rh(scenario: &ScenarioView, result: &ResultView) -> Checked<()> {
    let mut expected_findings = BTreeSet::new();
    let mut expected_tripwires = BTreeSet::new();

    for (id, before) in &scenario.before {
        match scenario.after.get(id) {
            None if before.theorem.is_some() => add_state_change(*id, scenario, &mut expected_findings,
                &mut expected_tripwires),
            Some(after) if before.theorem != after.theorem => add_state_change(*id, scenario,
                &mut expected_findings, &mut expected_tripwires),
            _ => {}
        }
    }

    for certification in &scenario.certifications {
        expected_tripwires.insert(theorem_tripwire(certification.id, certification.execution,
            certification.object, certification.performed));
        if certification.performed && scenario.after.get(&certification.object)
            .is_some_and(|object| object.role == ROLE_THEOREM) {
            expected_findings.insert(theorem_finding(certification.execution, certification.object,
                certification.capability, scenario.transition_id));
        }
    }

    if let Some(claim) = scenario.formal_claim {
        let performed = scenario.certifications.iter().any(|access| access.object == claim && access.performed);
        expected_tripwires.insert(theorem_tripwire(0, scenario.execution_id, claim, performed));
        let safe_stop = !scenario.goal_satisfied && scenario.boundary_reached &&
            scenario.terminal == TERMINAL_BLOCKED && !performed;
        if !safe_stop {
            expected_findings.insert(theorem_finding(scenario.execution_id, claim, 0,
                scenario.transition_id));
        }
    }

    let mut verified_present = false;
    for (id, object) in &scenario.after {
        if object.theorem.is_some_and(|state| state.disposition == DISPOSITION_VERIFIED) {
            verified_present = true;
            expected_tripwires.insert(theorem_tripwire(0, scenario.execution_id, *id, true));
            expected_findings.insert(theorem_finding(scenario.execution_id, *id, 0,
                scenario.transition_id));
        }
    }

    let actual_findings: BTreeSet<Finding> = result.findings.iter()
        .filter(|finding| finding.code == UNVERIFIED).cloned().collect();
    let actual_tripwires: BTreeSet<Tripwire> = result.tripwires.iter()
        .filter(|tripwire| tripwire.kind == UNVERIFIED).cloned().collect();
    if actual_findings != expected_findings || actual_tripwires != expected_tripwires {
        return Err(Reject);
    }

    let theorem_needs_authority = scenario.formal_claim.is_some() || verified_present;
    let expected_eligible = result.findings.is_empty() && !theorem_needs_authority &&
        scenario.goal_satisfied && scenario.terminal == TERMINAL_COMPLETED;
    if result.eligible != expected_eligible { return Err(Reject); }
    let expected_status = if !result.findings.is_empty() {
        "REJECTED_CLOSURE"
    } else if scenario.terminal == TERMINAL_BLOCKED {
        "DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION"
    } else {
        "DECLARED_GRAPH_CLOSED"
    };
    if result.status != expected_status { return Err(Reject); }
    let theorem_trigger = scenario.formal_claim.is_some() || !expected_findings.is_empty();
    if theorem_trigger && result.eligible { return Err(Reject); }
    Ok(())
}

fn add_state_change(id: u32, scenario: &ScenarioView, findings: &mut BTreeSet<Finding>,
                    tripwires: &mut BTreeSet<Tripwire>) {
    findings.insert(theorem_finding(scenario.execution_id, id, 0, scenario.transition_id));
    tripwires.insert(theorem_tripwire(0, scenario.execution_id, id, true));
}

fn theorem_finding(execution: u32, object: u32, capability: u32, transition: u32) -> Finding {
    Finding { code: UNVERIFIED.to_owned(), execution, object, capability, transition }
}

fn theorem_tripwire(access: u32, execution: u32, object: u32, delta: bool) -> Tripwire {
    Tripwire { kind: UNVERIFIED.to_owned(), access, execution, object,
        reachability_delta: delta }
}

fn known_finding(value: &str) -> bool {
    ["INVALID_CAPABILITY_PROVENANCE", "CAPABILITY_AMPLIFICATION", "PURPOSE_MISMATCH",
     "PERFORMED_WITHOUT_CAPABILITY", "CREDENTIAL_USE_WITHOUT_GRANT", "AMBIENT_ENUMERATION",
     "SELF_GRANT", "FORBIDDEN_METHOD", "UNSAFE_BOUNDARY_TERMINAL", "TERMINAL_INCONSISTENT",
     "UNAUTHORIZED_PERSISTENCE", "UNAUTHORIZED_ROLE_CHANGE", "EXECUTABLE_ROLE_WITHOUT_CAPABILITY",
     "UNAUTHORIZED_SHARING", "UNAUTHORIZED_CHANNEL", "POLICY_MUTATION",
     "IMMUTABLE_SURFACE_CAPABILITY", "AUDIT_MISSING", "AUDIT_SUPPRESSED", "RESOURCE_EXCEEDED",
     "CHANGE_INDEX_ADVANCED", "UNVERIFIED_THEOREM_CLAIM", "OBJECT_REMOVED",
     "OBJECT_STATE_CONCEALMENT", "UNAUTHORIZED_OWNERSHIP_TRANSFER", "RESOURCE_COUNTER_MISMATCH"]
        .contains(&value)
}

fn known_tripwire(value: &str) -> bool {
    ["CAPABILITY_BOUNDARY", "CREDENTIAL_PROBE", "AMBIENT_ENUMERATION", "PERSISTENCE_ATTEMPT",
     "EXECUTABLE_INPUT", "ROLE_CHANGE", "CHILD_EXECUTION", "POLICY_MUTATION", "AUDIT_MUTATION",
     "CHANNEL_CONSTRUCTION", "UNVERIFIED_THEOREM_CLAIM"].contains(&value)
}

fn map_value(value: &Value) -> Checked<&BTreeMap<String, Value>> {
    if let Value::Map(value) = value { Ok(value) } else { Err(Reject) }
}

fn array_value(value: &Value) -> Checked<&[Value]> {
    if let Value::Array(value) = value { Ok(value) } else { Err(Reject) }
}

fn text_value(value: &Value) -> Checked<&str> {
    if let Value::Text(value) = value { Ok(value) } else { Err(Reject) }
}

fn unsigned(value: &Value) -> Checked<u64> {
    if let Value::Unsigned(value) = value { Ok(*value) } else { Err(Reject) }
}

fn bool_value(value: &Value) -> Checked<bool> {
    if let Value::Bool(value) = value { Ok(*value) } else { Err(Reject) }
}

fn required_id(value: &Value) -> Checked<u32> {
    let value = u32::try_from(unsigned(value)?).map_err(|_| Reject)?;
    if value == 0 { Err(Reject) } else { Ok(value) }
}

fn optional_id(value: &Value) -> Checked<Option<u32>> {
    let raw = unsigned(value)?;
    if raw == 0 { return Ok(None); }
    let value = u32::try_from(raw).map_err(|_| Reject)?;
    Ok(Some(value))
}

fn get<'a>(map: &'a BTreeMap<String, Value>, key: &str) -> Checked<&'a Value> {
    map.get(key).ok_or(Reject)
}

fn require_keys(map: &BTreeMap<String, Value>, keys: &[&str]) -> Checked<()> {
    if map.len() != keys.len() || keys.iter().any(|key| !map.contains_key(*key)) {
        Err(Reject)
    } else {
        Ok(())
    }
}

fn sha256(input: &[u8]) -> [u8; 32] {
    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
        0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
        0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
        0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
        0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
        0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
        0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
        0xc67178f2,
    ];
    let mut state = [0x6a09e667u32, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19];
    let bit_length = (input.len() as u64).wrapping_mul(8);
    let mut padded = Vec::with_capacity(input.len() + 72);
    padded.extend_from_slice(input);
    padded.push(0x80);
    while padded.len() % 64 != 56 { padded.push(0); }
    padded.extend_from_slice(&bit_length.to_be_bytes());

    for chunk in padded.chunks_exact(64) {
        let mut words = [0u32; 64];
        for (index, word) in words[..16].iter_mut().enumerate() {
            let start = index * 4;
            *word = u32::from_be_bytes([
                chunk[start], chunk[start + 1], chunk[start + 2], chunk[start + 3],
            ]);
        }
        for index in 16..64 {
            let s0 = words[index - 15].rotate_right(7) ^ words[index - 15].rotate_right(18) ^
                (words[index - 15] >> 3);
            let s1 = words[index - 2].rotate_right(17) ^ words[index - 2].rotate_right(19) ^
                (words[index - 2] >> 10);
            words[index] = words[index - 16].wrapping_add(s0).wrapping_add(words[index - 7]).wrapping_add(s1);
        }
        let [mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut h] = state;
        for index in 0..64 {
            let big1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let choose = (e & f) ^ ((!e) & g);
            let first = h.wrapping_add(big1).wrapping_add(choose).wrapping_add(K[index])
                .wrapping_add(words[index]);
            let big0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let majority = (a & b) ^ (a & c) ^ (b & c);
            let second = big0.wrapping_add(majority);
            h = g; g = f; f = e; e = d.wrapping_add(first);
            d = c; c = b; b = a; a = first.wrapping_add(second);
        }
        state[0] = state[0].wrapping_add(a); state[1] = state[1].wrapping_add(b);
        state[2] = state[2].wrapping_add(c); state[3] = state[3].wrapping_add(d);
        state[4] = state[4].wrapping_add(e); state[5] = state[5].wrapping_add(f);
        state[6] = state[6].wrapping_add(g); state[7] = state[7].wrapping_add(h);
    }
    let mut output = [0u8; 32];
    for (index, word) in state.iter().enumerate() {
        output[index * 4..index * 4 + 4].copy_from_slice(&word.to_be_bytes());
    }
    output
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Cursor;

    fn map(entries: &[(&str, Value)]) -> Value {
        Value::Map(entries.iter().map(|(key, value)| ((*key).to_owned(), value.clone())).collect())
    }

    fn u(value: u64) -> Value { Value::Unsigned(value) }
    fn b(value: bool) -> Value { Value::Bool(value) }
    fn t(value: &str) -> Value { Value::Text(value.to_owned()) }
    fn a(values: Vec<Value>) -> Value { Value::Array(values) }

    fn object(role: u64, theorem: Vec<Value>) -> Value {
        a(vec![u(10), u(101), u(role), b(false), b(false), b(false), b(false), b(false),
            u(1), u(1), a(theorem)])
    }

    fn transition(goal: Value, satisfied: bool, boundary: bool, terminal: u64) -> Value {
        map(&[
            ("id", u(1001)), ("execution", u(101)), ("purpose", u(77)), ("goal", goal),
            ("before_caps", a(vec![])), ("after_caps", a(vec![])),
            ("policy_before", t(POLICY_ID)), ("policy_after", t(POLICY_ID)),
            ("generation_before", u(1)), ("generation_after", u(1)),
            ("goal_satisfied", b(satisfied)), ("boundary_reached", b(boundary)),
            ("terminal", u(terminal)), ("chi_before", u(4)), ("chi_after", u(4)),
            ("resources", a(vec![u(10), u(20), u(4096), u(0), u(1), u(0), u(0), u(0), u(128)])),
        ])
    }

    fn scenario(object: Value, transition: Value, accesses: Vec<Value>) -> Value {
        map(&[
            ("schema", t(SCENARIO_SCHEMA)),
            ("roots", a(vec![a(vec![u(1), t(POLICY_ID), u(1)])])),
            ("before_objects", a(vec![object.clone()])), ("after_objects", a(vec![object])),
            ("grants", a(vec![])), ("capabilities", a(vec![])),
            ("executions", a(vec![a(vec![u(101), u(1), u(77), a(vec![])])])),
            ("transition", transition), ("accesses", a(accesses)), ("evidence", a(vec![])),
            ("verifier", u(900)),
        ])
    }

    fn scenario_with_evidence(object: Value, transition: Value, accesses: Vec<Value>,
                              evidence: Vec<Value>) -> Value {
        let mut value = scenario(object, transition, accesses);
        if let Value::Map(ref mut root) = value {
            root.insert("evidence".to_owned(), a(evidence));
        }
        value
    }

    fn access_value(access: &AccessRecord) -> Value {
        a(vec![u(access.id as u64), u(access.execution as u64), u(access.object as u64),
            u(access.operation), u(access.method), u(access.peer as u64),
            u(access.capability as u64), u(access.outcome), u(access.phase)])
    }

    fn evidence_value(access: &AccessRecord, sequence: u64, verifier: u64,
                      digest: [u8; 32], suppressed: bool) -> Value {
        a(vec![u(2000), u(access.id as u64), u(sequence), u(verifier),
            Value::Bytes(digest.to_vec()), b(suppressed)])
    }

    fn result(status: &str, findings: Vec<Value>, tripwires: Vec<Value>, eligible: bool) -> Value {
        map(&[
            ("schema", t(REPORT_SCHEMA)), ("status", t(status)), ("findings", a(findings)),
            ("channels", a(vec![])), ("tripwires", a(tripwires)),
            ("commit_candidate_eligible", b(eligible)), ("change_index_delta", u(0)),
        ])
    }

    fn rh_tripwire(access: u64, delta: bool) -> Value {
        a(vec![t(UNVERIFIED), u(access), u(101), u(10), b(delta)])
    }

    fn hex(bytes: &[u8]) -> String {
        const DIGITS: &[u8; 16] = b"0123456789abcdef";
        let mut result = String::with_capacity(bytes.len() * 2);
        for byte in bytes {
            result.push(DIGITS[(byte >> 4) as usize] as char);
            result.push(DIGITS[(byte & 15) as usize] as char);
        }
        result
    }

    fn frame(scenario: &[u8], result: &[u8], root: [u8; 32]) -> Vec<u8> {
        let mut bytes = Vec::new();
        bytes.extend_from_slice(MAGIC);
        bytes.extend_from_slice(&VERSION.to_be_bytes());
        bytes.extend_from_slice(&0u16.to_be_bytes());
        bytes.extend_from_slice(&(scenario.len() as u32).to_be_bytes());
        bytes.extend_from_slice(&(result.len() as u32).to_be_bytes());
        bytes.extend_from_slice(hex(&root).as_bytes());
        bytes.extend_from_slice(scenario);
        bytes.extend_from_slice(result);
        bytes
    }

    #[test]
    fn sha256_known_answer_tests() {
        assert_eq!(hex(&sha256(b"")), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
        assert_eq!(hex(&sha256(b"abc")), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
        assert_eq!(hex(&sha256(&vec![b'a'; 1_000_000])),
            "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0");
        assert_eq!(hex(&receipt_root(&[0xa0], &[0xa0]).unwrap()),
            "2a1af18dc5926e1a6e69a8539a789254f18bd493af50425e27f0fe0c3dbb6966");
        let access = AccessRecord { id: 1, execution: 101, object: 10,
            operation: 18, method: 5, peer: 0, capability: 0,
            outcome: 0, phase: 1 };
        assert_eq!(hex(&access_evidence_digest(&access).unwrap()),
            "968cd8fb1656b6f5855dbe2b31a034db6ccb57893a78891c93a5a8699bb7d660");
    }

    #[test]
    fn canonical_cbor_rejects_aliases_and_bad_order() {
        assert!(decode_canonical(&[0x18, 0x00]).is_err());
        assert!(decode_canonical(&[0xbf, 0xff]).is_err());
        assert!(decode_canonical(&[0xa2, 0x61, b'b', 0x00, 0x61, b'a', 0x00]).is_err());
        assert!(decode_canonical(&[0x61, 0xff]).is_err());
    }

    #[test]
    fn ordinary_and_rh_safe_stop_frames_validate() {
        let ordinary_scenario = encode_canonical(&scenario(object(3, vec![]),
            transition(a(vec![u(0), u(10)]), true, false, 1), vec![])).unwrap();
        let ordinary_result = encode_canonical(&result("DECLARED_GRAPH_CLOSED", vec![], vec![], true)).unwrap();
        let ordinary_root = receipt_root(&ordinary_scenario, &ordinary_result).unwrap();
        assert!(verify_reader(Cursor::new(frame(&ordinary_scenario, &ordinary_result, ordinary_root))).is_ok());

        let claim = object(ROLE_THEOREM, vec![u(RH), u(1)]);
        let rh_scenario = encode_canonical(&scenario(claim,
            transition(a(vec![u(1), u(RH), u(10)]), false, true, TERMINAL_BLOCKED), vec![])).unwrap();
        let rh_result = encode_canonical(&result("DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION",
            vec![], vec![rh_tripwire(0, false)], false)).unwrap();
        let rh_root = receipt_root(&rh_scenario, &rh_result).unwrap();
        assert!(verify_reader(Cursor::new(frame(&rh_scenario, &rh_result, rh_root))).is_ok());
    }

    #[test]
    fn semantic_and_merkle_forgery_fail_closed() {
        let claim = object(ROLE_THEOREM, vec![u(RH), u(1)]);
        let laundered = encode_canonical(&scenario(claim.clone(),
            transition(a(vec![u(0), u(10)]), true, false, 1), vec![])).unwrap();
        let forged_result = encode_canonical(&result("DECLARED_GRAPH_CLOSED", vec![], vec![], true)).unwrap();
        let replacement_root = receipt_root(&laundered, &forged_result).unwrap();
        assert!(verify_receipt(&laundered, &forged_result, replacement_root).is_err());

        let denied = a(vec![u(1), u(101), u(10), u(OP_CERTIFY_THEOREM), u(5), u(0), u(0), u(99), u(1)]);
        let malformed = encode_canonical(&scenario(claim,
            transition(a(vec![u(1), u(RH), u(10)]), false, true, TERMINAL_BLOCKED), vec![denied])).unwrap();
        let blocked = encode_canonical(&result("DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION",
            vec![], vec![rh_tripwire(0, false)], false)).unwrap();
        let malformed_root = receipt_root(&malformed, &blocked).unwrap();
        assert!(verify_receipt(&malformed, &blocked, malformed_root).is_err());

        let mut wrong_root = replacement_root;
        wrong_root[0] ^= 1;
        assert!(verify_receipt(&laundered, &forged_result, wrong_root).is_err());

        let mut changed_index = scenario(object(3, vec![]),
            transition(a(vec![u(0), u(10)]), true, false, TERMINAL_COMPLETED), vec![]);
        let Value::Map(ref mut root) = changed_index else { unreachable!() };
        let Value::Map(transition) = root.get_mut("transition").unwrap() else {
            unreachable!()
        };
        transition.insert("chi_after".to_owned(), u(5));
        let changed_index = encode_canonical(&changed_index).unwrap();
        let ordinary_result = encode_canonical(
            &result("DECLARED_GRAPH_CLOSED", vec![], vec![], true)).unwrap();
        let changed_index_root = receipt_root(&changed_index, &ordinary_result).unwrap();
        assert!(verify_receipt(&changed_index, &ordinary_result, changed_index_root).is_err());
    }

    #[test]
    fn declared_trace_coverage_is_exact_and_digest_bound() {
        let claim = object(ROLE_THEOREM, vec![u(RH), u(1)]);
        let access = AccessRecord { id: 1, execution: 101, object: 10,
            operation: OP_CERTIFY_THEOREM, method: 5, peer: 0, capability: 0,
            outcome: 0, phase: 1 };
        let digest = access_evidence_digest(&access).unwrap();
        let transition = transition(a(vec![u(1), u(RH), u(10)]), false, true, TERMINAL_BLOCKED);
        let result = encode_canonical(&result("DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION",
            vec![], vec![rh_tripwire(0, false), rh_tripwire(1, false)], false)).unwrap();

        let valid = encode_canonical(&scenario_with_evidence(claim.clone(), transition.clone(),
            vec![access_value(&access)],
            vec![evidence_value(&access, 0, 900, digest, false)])).unwrap();
        let valid_root = receipt_root(&valid, &result).unwrap();
        assert!(verify_receipt(&valid, &result, valid_root).is_ok());

        let mut bad_digest = digest;
        bad_digest[0] ^= 1;
        let invalid_evidence = vec![
            vec![],
            vec![evidence_value(&access, 1, 900, digest, false)],
            vec![evidence_value(&access, 0, 901, digest, false)],
            vec![evidence_value(&access, 0, 900, bad_digest, false)],
            vec![evidence_value(&access, 0, 900, digest, true)],
        ];
        for evidence in invalid_evidence {
            let scenario = encode_canonical(&scenario_with_evidence(claim.clone(), transition.clone(),
                vec![access_value(&access)], evidence)).unwrap();
            let root = receipt_root(&scenario, &result).unwrap();
            assert!(verify_receipt(&scenario, &result, root).is_err());
        }

        let unknown_access = AccessRecord { id: 2, ..access.clone() };
        let mismatched = encode_canonical(&scenario_with_evidence(claim, transition,
            vec![access_value(&access)],
            vec![evidence_value(&unknown_access, 0, 900,
                access_evidence_digest(&unknown_access).unwrap(), false)])).unwrap();
        let mismatched_root = receipt_root(&mismatched, &result).unwrap();
        assert!(verify_receipt(&mismatched, &result, mismatched_root).is_err());
    }

    #[test]
    fn structural_generation_capability_and_grant_joins_are_closed() {
        fn joined_scenario(access_capability: u32, generation: u64) -> Value {
            let access = AccessRecord { id: 1, execution: 101, object: 10,
                operation: 2, method: 1, peer: 0, capability: access_capability,
                outcome: 0, phase: 1 };
            let digest = access_evidence_digest(&access).unwrap();
            let mut value = scenario_with_evidence(object(3, vec![]),
                transition(a(vec![u(0), u(10)]), true, false, TERMINAL_COMPLETED),
                vec![access_value(&access)],
                vec![evidence_value(&access, 0, 900, digest, false)]);
            let Value::Map(ref mut root) = value else { unreachable!() };
            root.insert("grants".to_owned(), a(vec![a(vec![
                u(600), a(vec![u(0), u(1)]), u(101), u(10), u(2), u(1), u(77), u(0),
                u(1), u(1), b(false), b(false), b(true), u(0),
            ])]));
            root.insert("capabilities".to_owned(), a(vec![a(vec![u(500), u(600)])]));
            root.insert("executions".to_owned(),
                a(vec![a(vec![u(101), u(generation), u(77), a(vec![u(500)])])]));
            let Value::Map(transition) = root.get_mut("transition").unwrap() else {
                unreachable!()
            };
            transition.insert("before_caps".to_owned(), a(vec![u(500)]));
            transition.insert("after_caps".to_owned(), a(vec![u(500)]));
            value
        }

        let result = encode_canonical(&result("DECLARED_GRAPH_CLOSED", vec![], vec![], true)).unwrap();
        let valid = encode_canonical(&joined_scenario(500, 1)).unwrap();
        let valid_root = receipt_root(&valid, &result).unwrap();
        assert!(verify_receipt(&valid, &result, valid_root).is_ok());

        let missing_capability = encode_canonical(&joined_scenario(999, 1)).unwrap();
        let missing_capability_root = receipt_root(&missing_capability, &result).unwrap();
        assert!(verify_receipt(&missing_capability, &result, missing_capability_root).is_err());

        let zero_generation = encode_canonical(&joined_scenario(500, 0)).unwrap();
        let zero_generation_root = receipt_root(&zero_generation, &result).unwrap();
        assert!(verify_receipt(&zero_generation, &result, zero_generation_root).is_err());

        let mut missing_grant = joined_scenario(500, 1);
        let Value::Map(ref mut root) = missing_grant else { unreachable!() };
        root.insert("grants".to_owned(), a(vec![]));
        let missing_grant = encode_canonical(&missing_grant).unwrap();
        let missing_grant_root = receipt_root(&missing_grant, &result).unwrap();
        assert!(verify_receipt(&missing_grant, &result, missing_grant_root).is_err());
    }

    #[test]
    fn framing_requires_exact_eof_and_lowercase_root() {
        let scenario = encode_canonical(&scenario(object(3, vec![]),
            transition(a(vec![u(0), u(10)]), true, false, 1), vec![])).unwrap();
        let result = encode_canonical(&result("DECLARED_GRAPH_CLOSED", vec![], vec![], true)).unwrap();
        let root = receipt_root(&scenario, &result).unwrap();
        let mut bytes = frame(&scenario, &result, root);
        bytes.push(0);
        assert!(verify_reader(Cursor::new(bytes)).is_err());
        assert!(decode_lower_hex_32(b"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").is_err());
    }
}
