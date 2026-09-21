#![no_std]
#![no_main]

use core::arch::{asm, global_asm};
use core::panic::PanicInfo;

global_asm!(include_str!("entry.S"));

// Shared-memory reads/writes and intentional traps belong to the assembly shim.
// Zero is reserved for rejection; this bootstrap admits only the fixed fixture.
const fn evaluate(sequence: u64, abi: u64, left: u64, right: u64) -> u64 {
    if sequence != 1 || abi != 1 || left != 19 || right != 23 {
        return 0;
    }
    match left.checked_add(right) {
        Some(42) => 42,
        _ => 0,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn epr_guest_evaluate(sequence: u64, abi: u64, left: u64, right: u64) -> u64 {
    evaluate(sequence, abi, left, right)
}

// Compile-time semantics only: no host test binary or guest is executed.
const _: () = {
    assert!(evaluate(1, 1, 19, 23) == 42);
    assert!(evaluate(0, 1, 19, 23) == 0);
    assert!(evaluate(2, 1, 19, 23) == 0);
    assert!(evaluate(1, 0, 19, 23) == 0);
    assert!(evaluate(1, 2, 19, 23) == 0);
    assert!(evaluate(1, 1, 18, 23) == 0);
    assert!(evaluate(1, 1, 19, 24) == 0);
    assert!(evaluate(1, 1, 23, 19) == 0);
    assert!(evaluate(1, 1, u64::MAX, 1) == 0);
};

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    // No Rust memory access attempts the MMIO fault; this is a named code trap.
    unsafe { asm!("b epr_guest_panic", options(noreturn, nomem, nostack)) }
}
