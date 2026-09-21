/* Standalone fault/cancellation/conservation coverage for the actual native
 * H3 controller. This translation unit includes HypervisorGuest.c and replaces
 * every authority-bearing boundary before preprocessing it. The production H3
 * function, ordering, cleanup and reservation state machine run unchanged;
 * no Hypervisor symbol, guest instruction, process, signal, file or network
 * operation is entered. This file is not in either application target.
 *
 * Compile with the macOS SDK, C11, -Wall -Wextra -Werror and -pthread. */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <sched.h>

typedef enum {
    TEST_OP_NONE,
    TEST_OP_ALLOCATE,
    TEST_OP_VM_CREATE,
    TEST_OP_MAP,
    TEST_OP_VCPU_CREATE,
    TEST_OP_REGISTER,
    TEST_OP_WATCHDOG_CREATE,
    TEST_OP_RUN,
    TEST_OP_READ,
    TEST_OP_SOURCE_PRE_ENTRY_SCTLR_READ,
    TEST_OP_SOURCE_POST_EXIT_SCTLR_READ,
    TEST_OP_TERMINAL_READ,
    TEST_OP_WATCHDOG_JOIN,
    TEST_OP_VCPU_DESTROY,
    TEST_OP_UNMAP,
    TEST_OP_VM_DESTROY,
    TEST_OP_HOST_UNMAP,
    TEST_OP_COUNT
} TestOperation;

typedef enum {
    TEST_CANCEL_NONE,
    TEST_CANCEL_PRE_SETUP,
    TEST_CANCEL_PRE_SOURCE_RUN,
    TEST_CANCEL_SOURCE_RUN,
    TEST_CANCEL_BETWEEN_PHASES,
    TEST_CANCEL_TARGET_RUN,
    TEST_CANCEL_SOURCE_RUN_CONCURRENT,
    TEST_CANCEL_TARGET_RUN_CONCURRENT,
    TEST_CANCEL_WATCHDOG_TIMEOUT,
    TEST_CANCEL_UI_WATCHDOG_RACE
} TestCancellation;

/* Rename every external effect used by the included production controller.
 * The SDK declarations are renamed too, so the stubs below retain the exact
 * platform signatures and the compiler diagnoses drift. */
#define mmap h3_test_mmap
#define mprotect h3_test_mprotect
#define munmap h3_test_munmap
#define sys_icache_invalidate h3_test_icache_invalidate
#define epr_admit_signing h3_test_admit_signing
#define pthread_main_np h3_test_pthread_main_np
#define pthread_create h3_test_pthread_create
#define pthread_join h3_test_pthread_join
#define pthread_cond_timedwait_relative_np h3_test_pthread_cond_timedwait_relative_np
#define mach_absolute_time h3_test_mach_absolute_time
#define hv_vm_create h3_test_hv_vm_create
#define hv_vm_map h3_test_hv_vm_map
#define hv_vcpu_create h3_test_hv_vcpu_create
#define hv_vcpu_set_reg h3_test_hv_vcpu_set_reg
#define hv_vcpu_set_sys_reg h3_test_hv_vcpu_set_sys_reg
#define hv_vcpu_run h3_test_hv_vcpu_run
#define hv_vcpu_get_reg h3_test_hv_vcpu_get_reg
#define hv_vcpu_get_sys_reg h3_test_hv_vcpu_get_sys_reg
#define hv_vcpu_destroy h3_test_hv_vcpu_destroy
#define hv_vm_unmap h3_test_hv_vm_unmap
#define hv_vm_destroy h3_test_hv_vm_destroy
#define hv_vcpus_exit h3_test_hv_vcpus_exit
#include "../Sources/HypervisorGuest.c"
#undef mmap
#undef mprotect
#undef munmap
#undef sys_icache_invalidate
#undef epr_admit_signing
#undef pthread_main_np
#undef pthread_create
#undef pthread_join
#undef pthread_cond_timedwait_relative_np
#undef mach_absolute_time
#undef hv_vm_create
#undef hv_vm_map
#undef hv_vcpu_create
#undef hv_vcpu_set_reg
#undef hv_vcpu_set_sys_reg
#undef hv_vcpu_run
#undef hv_vcpu_get_reg
#undef hv_vcpu_get_sys_reg
#undef hv_vcpu_destroy
#undef hv_vm_unmap
#undef hv_vm_destroy
#undef hv_vcpus_exit

/* The first include renamed these platform declarations. Restore only the
 * four inert pthread/clock primitives used by the test harness itself. */
extern uint64_t mach_absolute_time(void);
extern int pthread_create(pthread_t *restrict, const pthread_attr_t *restrict,
                          void *(*)(void *), void *restrict);
extern int pthread_join(pthread_t, void **);
extern int pthread_cond_timedwait_relative_np(pthread_cond_t *, pthread_mutex_t *,
                                              const struct timespec *);

#include <stdio.h>

#define CHECK(value) do { if (!(value)) { \
    fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #value); return 1; \
} } while (0)

enum { test_phase_source = 1, test_phase_target = 2, test_block_count = 8 };

typedef struct {
    int fault_phase;
    TestOperation fault_operation;
    TestCancellation cancellation;
    uint32_t checkpoint_fault_mask;
    bool source_pre_entry_sctlr_override;
    bool source_post_exit_sctlr_override;
    uint64_t source_pre_entry_sctlr;
    uint64_t source_post_exit_sctlr;
    bool fault_consumed;
    bool real_watchdog_threads;
    bool bounded_watchdog_timeout;
    EPRGuestReservation *token;
} TestConfiguration;

static TestConfiguration configuration;
static int current_phase;
static unsigned calls[2][TEST_OP_COUNT];
static unsigned vm_create_calls[2], run_calls[2], successful_host_unmaps[2];
static _Atomic(unsigned) exit_calls;
static unsigned ordering_violations;
static bool source_conserved_before_target;
static pthread_t owner_thread[2];
static bool owner_thread_set[2], owner_thread_mismatch;
static hv_vcpu_exit_t exits[2];
static uint64_t registers[2][64];
static uint64_t system_registers[2][3];
static unsigned char *mapped_pages[2][3];
static bool fake_vm_live[2], fake_vcpu_live[2];
static _Alignas(16384) unsigned char allocation_blocks[test_block_count][32768];
static bool allocation_in_use[test_block_count];
static _Atomic(bool) force_deadline_elapsed;
static _Atomic(bool) ui_watchdog_race_release;
static _Atomic(unsigned) real_watchdog_started, real_watchdog_exited;
static pthread_mutex_t exit_event_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t exit_event_condition = PTHREAD_COND_INITIALIZER;

typedef struct {
    void *(*start)(void *);
    void *argument;
} RealWatchdogStart;
static RealWatchdogStart real_watchdog_starts[2];

static int phase_index(void) { return current_phase - 1; }

static bool fail_now(TestOperation operation) {
    int index = phase_index();
    if (index >= 0 && index < 2) ++calls[index][operation];
    if (!configuration.fault_consumed &&
        configuration.fault_phase == current_phase &&
        configuration.fault_operation == operation) {
        configuration.fault_consumed = true;
        return true;
    }
    return false;
}

static void observe_owner_thread(int index) {
    pthread_t now = pthread_self();
    if (!owner_thread_set[index]) {
        owner_thread[index] = now;
        owner_thread_set[index] = true;
    } else if (!pthread_equal(owner_thread[index], now)) {
        owner_thread_mismatch = true;
    }
}

static int region_index(hv_ipa_t ipa) {
    if (ipa == UINT64_C(0x10000000)) return 0;
    if (ipa == UINT64_C(0x10004000)) return 1;
    if (ipa == UINT64_C(0x10008000)) return 2;
    return -1;
}

static int sys_index(hv_sys_reg_t reg) {
    if (reg == HV_SYS_REG_SCTLR_EL1) return 0;
    if (reg == HV_SYS_REG_SP_EL1) return 1;
    if (reg == HV_SYS_REG_VBAR_EL1) return 2;
    return -1;
}

static bool all_fake_resources_gone(void) {
    for (int phase = 0; phase < 2; ++phase) {
        if (fake_vm_live[phase] || fake_vcpu_live[phase]) return false;
        for (int region = 0; region < 3; ++region)
            if (mapped_pages[phase][region]) return false;
    }
    for (size_t block = 0; block < test_block_count; ++block)
        if (allocation_in_use[block]) return false;
    return true;
}

void *h3_test_mmap(void *address, size_t length, int protection,
                   int flags, int descriptor, off_t offset) {
    (void)address; (void)protection; (void)flags; (void)descriptor; (void)offset;
    bool injected = fail_now(TEST_OP_ALLOCATE);
    if (current_phase == test_phase_source &&
        calls[0][TEST_OP_ALLOCATE] > h3_region_count) ++ordering_violations;
    if (length != allocation_size || injected) {
        errno = length == allocation_size ? ENOMEM : EINVAL;
        return MAP_FAILED;
    }
    for (size_t i = 0; i < test_block_count; ++i) if (!allocation_in_use[i]) {
        allocation_in_use[i] = true;
        memset(allocation_blocks[i], 0, sizeof(allocation_blocks[i]));
        return allocation_blocks[i];
    }
    errno = ENOMEM;
    return MAP_FAILED;
}

int h3_test_mprotect(void *address, size_t length, int protection) {
    (void)address; (void)length; (void)protection;
    return 0;
}

int h3_test_munmap(void *address, size_t length) {
    bool injected = fail_now(TEST_OP_HOST_UNMAP);
    if (length != allocation_size) { errno = EINVAL; return -1; }
    size_t block = test_block_count;
    for (size_t i = 0; i < test_block_count; ++i)
        if (address == allocation_blocks[i]) { block = i; break; }
    if (block == test_block_count || !allocation_in_use[block]) {
        errno = EINVAL; return -1;
    }
    if (injected) { errno = EIO; return -1; }
    allocation_in_use[block] = false;
    int index = phase_index();
    if (++successful_host_unmaps[index] == 3 && current_phase == test_phase_source) {
        source_conserved_before_target = true;
        current_phase = test_phase_target;
        if (configuration.cancellation == TEST_CANCEL_BETWEEN_PHASES) {
            (void)epr_guest_reservation_cancel(configuration.token);
            (void)epr_guest_reservation_cancel(configuration.token);
        }
    }
    return 0;
}

void h3_test_icache_invalidate(void *start, size_t length) {
    (void)start; (void)length;
}

int h3_test_admit_signing(const char *team, int *error) {
    if (!team || strcmp(team, "ZCQ435U8JP")) { if (error) *error = EINVAL; return 0; }
    if (error) *error = 0;
    return 1;
}

int h3_test_pthread_main_np(void) { return 0; }

uint64_t h3_test_mach_absolute_time(void) {
    if (atomic_load_explicit(&force_deadline_elapsed, memory_order_seq_cst))
        return UINT64_MAX - 1;
    return mach_absolute_time();
}

int h3_test_pthread_cond_timedwait_relative_np(pthread_cond_t *condition,
                                               pthread_mutex_t *mutex,
                                               const struct timespec *interval) {
    if (!configuration.bounded_watchdog_timeout)
        return pthread_cond_timedwait_relative_np(condition, mutex, interval);
    const struct timespec bounded = { .tv_sec = 0, .tv_nsec = 5000000 };
    int status = pthread_cond_timedwait_relative_np(condition, mutex, &bounded);
    if (status == ETIMEDOUT) {
        atomic_store_explicit(&force_deadline_elapsed, true, memory_order_seq_cst);
        atomic_store_explicit(&ui_watchdog_race_release, true, memory_order_seq_cst);
    }
    return status;
}

static void *real_watchdog_entry(void *opaque) {
    RealWatchdogStart *entry = opaque;
    atomic_fetch_add_explicit(&real_watchdog_started, 1, memory_order_seq_cst);
    void *result = entry->start(entry->argument);
    atomic_fetch_add_explicit(&real_watchdog_exited, 1, memory_order_seq_cst);
    return result;
}

int h3_test_pthread_create(pthread_t *restrict thread,
                           const pthread_attr_t *restrict attributes,
                           void *(*start)(void *), void *restrict argument) {
    if (fail_now(TEST_OP_WATCHDOG_CREATE)) return EAGAIN;
    if (configuration.real_watchdog_threads) {
        int index = phase_index();
        real_watchdog_starts[index] = (RealWatchdogStart){
            .start = start, .argument = argument
        };
        int status = pthread_create(thread, attributes, real_watchdog_entry,
                                    &real_watchdog_starts[index]);
        if (!status && current_phase == test_phase_source &&
            configuration.cancellation == TEST_CANCEL_PRE_SOURCE_RUN) {
            (void)epr_guest_reservation_cancel(configuration.token);
            (void)epr_guest_reservation_cancel(configuration.token);
        }
        return status;
    }
    (void)attributes; (void)start; (void)argument;
    *thread = (pthread_t)(uintptr_t)(UINT64_C(0x1000) + (uint64_t)current_phase);
    return 0;
}

int h3_test_pthread_join(pthread_t thread, void **value) {
    bool injected = fail_now(TEST_OP_WATCHDOG_JOIN);
    if (injected) return ESRCH;
    if (configuration.real_watchdog_threads) return pthread_join(thread, value);
    (void)thread; (void)value;
    return 0;
}

hv_return_t h3_test_hv_vm_create(hv_vm_config_t config) {
    (void)config;
    int index = phase_index();
    ++vm_create_calls[index];
    if (current_phase == test_phase_source && vm_create_calls[0] > 1)
        ++ordering_violations;
    if (current_phase == test_phase_target && !source_conserved_before_target) {
        ++ordering_violations;
        return HV_ERROR;
    }
    if (fail_now(TEST_OP_VM_CREATE)) return HV_ERROR;
    fake_vm_live[index] = true;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vm_map(void *address, hv_ipa_t ipa, size_t length,
                              hv_memory_flags_t flags) {
    int region = region_index(ipa);
    if (region < 0 || length != slot_size ||
        flags != (hv_memory_flags_t)h3_regions[region].rights) return HV_BAD_ARGUMENT;
    if (fail_now(TEST_OP_MAP)) return HV_ERROR;
    mapped_pages[phase_index()][region] = address;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpu_create(hv_vcpu_t *vcpu,
                                   hv_vcpu_exit_t **exit,
                                   hv_vcpu_config_t config) {
    (void)config;
    int index = phase_index();
    observe_owner_thread(index);
    if (fail_now(TEST_OP_VCPU_CREATE)) return HV_ERROR;
    *vcpu = (hv_vcpu_t)(UINT64_C(0x2000) + (uint64_t)current_phase);
    memset(&exits[index], 0, sizeof(exits[index]));
    *exit = &exits[index];
    fake_vcpu_live[index] = true;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpu_set_reg(hv_vcpu_t vcpu, hv_reg_t reg,
                                    uint64_t value) {
    (void)vcpu;
    if (fail_now(TEST_OP_REGISTER)) return HV_ERROR;
    if ((unsigned)reg >= 64) return HV_BAD_ARGUMENT;
    registers[phase_index()][reg] = value;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpu_set_sys_reg(hv_vcpu_t vcpu, hv_sys_reg_t reg,
                                        uint64_t value) {
    (void)vcpu;
    if (fail_now(TEST_OP_REGISTER)) return HV_ERROR;
    int index = sys_index(reg);
    if (index < 0) return HV_BAD_ARGUMENT;
    system_registers[phase_index()][index] = value;
    return HV_SUCCESS;
}

static void synthesize_exit(int index) {
    unsigned char *reply = mapped_pages[index][2];
    exits[index].reason = HV_EXIT_REASON_EXCEPTION;
    exits[index].exception.syndrome = UINT64_C(0x93840044);
    exits[index].exception.physical_address = h3_doorbell_ipa;
    exits[index].exception.virtual_address = h3_doorbell_ipa;
    if (index == 0) {
        registers[index][HV_REG_X0] = h3_regions[1].ipa;
        registers[index][HV_REG_X1] = h3_regions[2].ipa;
        registers[index][HV_REG_X3] = h3_doorbell_ipa;
        registers[index][HV_REG_X4] = 1;
        registers[index][HV_REG_X5] = 1;
        registers[index][HV_REG_X6] = 42;
        registers[index][HV_REG_X7] = 23;
        registers[index][HV_REG_PC] = code_ipa + h3_checkpoint_offset;
        registers[index][HV_REG_CPSR] = UINT64_C(0x600003c5);
        memcpy(reply, expected_reply, sizeof(expected_reply));
        atomic_store_explicit((_Atomic(uint64_t) *)reply, 1, memory_order_release);
    } else {
        registers[index][HV_REG_X4] = 2;
        registers[index][HV_REG_X8] = 43;
        registers[index][HV_REG_PC] = code_ipa + h3_terminal_offset;
        memcpy(reply, h3_expected_terminal_reply, sizeof(h3_expected_terminal_reply));
        atomic_store_explicit((_Atomic(uint64_t) *)reply, 2, memory_order_release);
    }
}

enum { TEST_CHECKPOINT_TRAP = UINT32_C(1) << 31 };

static void inject_checkpoint_faults(void) {
    uint32_t faults = configuration.checkpoint_fault_mask;
    if (!faults) return;
    unsigned char *code = mapped_pages[0][EPR_GUEST_H3_CP_PAGE_CODE];
    unsigned char *request = mapped_pages[0][EPR_GUEST_H3_CP_PAGE_REQUEST];
    unsigned char *reply = mapped_pages[0][EPR_GUEST_H3_CP_PAGE_REPLY];
    if (faults & TEST_CHECKPOINT_TRAP)
        exits[0].exception.syndrome = 0;
    if (faults & EPR_GUEST_H3_CP_SEQUENCE)
        atomic_store_explicit((_Atomic(uint64_t) *)reply, 9, memory_order_release);
    if (faults & EPR_GUEST_H3_CP_CODE_PAGE)
        code[sizeof(h3_guest_image)] = UINT8_C(0xa1);
    if (faults & EPR_GUEST_H3_CP_REQUEST_PAGE)
        request[sizeof(expected_request)] = UINT8_C(0xb2);
    if (faults & EPR_GUEST_H3_CP_REPLY_PAGE)
        reply[24] = UINT8_C(0xc3);
    if (faults & EPR_GUEST_H3_CP_GPRS) {
        registers[0][HV_REG_X6] = h3_expected_checkpoint_gpr(6) ^ 1;
    }
    if (faults & EPR_GUEST_H3_CP_CPSR)
        registers[0][HV_REG_CPSR] ^= UINT64_C(1) << 28;
    if (faults & EPR_GUEST_H3_CP_SCTLR)
        system_registers[0][0] ^= 1;
    if (faults & EPR_GUEST_H3_CP_SP)
        system_registers[0][1] -= 16;
    if (faults & EPR_GUEST_H3_CP_VBAR)
        system_registers[0][2] = UINT64_C(0x10000000);
}

static void *concurrent_ui_cancel(void *opaque) {
    EPRGuestReservation *token = opaque;
    if (configuration.cancellation == TEST_CANCEL_UI_WATCHDOG_RACE) {
        while (!atomic_load_explicit(&ui_watchdog_race_release,
                                     memory_order_seq_cst)) sched_yield();
    }
    (void)epr_guest_reservation_cancel(token);
    (void)epr_guest_reservation_cancel(token);
    return NULL;
}

static bool wait_for_exit_request(void) {
    const struct timespec limit = { .tv_sec = 0, .tv_nsec = 200000000 };
    pthread_mutex_lock(&exit_event_lock);
    int status = 0;
    while (!atomic_load_explicit(&exit_calls, memory_order_seq_cst) && !status)
        status = pthread_cond_timedwait_relative_np(&exit_event_condition,
                                                    &exit_event_lock, &limit);
    bool observed = atomic_load_explicit(&exit_calls, memory_order_seq_cst) != 0;
    pthread_mutex_unlock(&exit_event_lock);
    return observed;
}

hv_return_t h3_test_hv_vcpu_run(hv_vcpu_t vcpu) {
    (void)vcpu;
    int index = phase_index();
    observe_owner_thread(index);
    ++run_calls[index];
    if (fail_now(TEST_OP_RUN)) return HV_ERROR;
    if ((current_phase == test_phase_source &&
         configuration.cancellation == TEST_CANCEL_SOURCE_RUN) ||
        (current_phase == test_phase_target &&
         configuration.cancellation == TEST_CANCEL_TARGET_RUN)) {
        (void)epr_guest_reservation_cancel(configuration.token);
        (void)epr_guest_reservation_cancel(configuration.token);
    }
    bool concurrent_cancel =
        (current_phase == test_phase_source &&
         (configuration.cancellation == TEST_CANCEL_SOURCE_RUN_CONCURRENT ||
          configuration.cancellation == TEST_CANCEL_UI_WATCHDOG_RACE)) ||
        (current_phase == test_phase_target &&
         configuration.cancellation == TEST_CANCEL_TARGET_RUN_CONCURRENT);
    pthread_t ui_thread = 0;
    if (concurrent_cancel &&
        pthread_create(&ui_thread, NULL, concurrent_ui_cancel,
                       configuration.token)) return HV_ERROR;
    if (configuration.cancellation == TEST_CANCEL_WATCHDOG_TIMEOUT ||
        configuration.cancellation == TEST_CANCEL_UI_WATCHDOG_RACE) {
        if (!wait_for_exit_request()) return HV_ERROR;
    }
    if (concurrent_cancel && pthread_join(ui_thread, NULL)) return HV_ERROR;
    synthesize_exit(index);
    if (index == 0) inject_checkpoint_faults();
    return HV_SUCCESS;
}

static TestOperation read_operation(void) {
    return current_phase == test_phase_target && run_calls[1] ?
        TEST_OP_TERMINAL_READ : TEST_OP_READ;
}

hv_return_t h3_test_hv_vcpu_get_reg(hv_vcpu_t vcpu, hv_reg_t reg,
                                    uint64_t *value) {
    (void)vcpu;
    if (fail_now(read_operation())) return HV_ERROR;
    if (!value || (unsigned)reg >= 64) return HV_BAD_ARGUMENT;
    *value = registers[phase_index()][reg];
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpu_get_sys_reg(hv_vcpu_t vcpu, hv_sys_reg_t reg,
                                        uint64_t *value) {
    (void)vcpu;
    if (current_phase == test_phase_source && reg == HV_SYS_REG_SCTLR_EL1) {
        bool post_exit = run_calls[0] != 0;
        TestOperation operation = post_exit ?
            TEST_OP_SOURCE_POST_EXIT_SCTLR_READ :
            TEST_OP_SOURCE_PRE_ENTRY_SCTLR_READ;
        if (fail_now(operation)) return HV_ERROR;
        if (!post_exit && configuration.source_pre_entry_sctlr_override)
            system_registers[0][0] = configuration.source_pre_entry_sctlr;
        if (post_exit && configuration.source_post_exit_sctlr_override)
            system_registers[0][0] = configuration.source_post_exit_sctlr;
        if (!value) return HV_BAD_ARGUMENT;
        *value = system_registers[0][0];
        return HV_SUCCESS;
    }
    if (fail_now(read_operation())) return HV_ERROR;
    int index = sys_index(reg);
    if (!value || index < 0) return HV_BAD_ARGUMENT;
    *value = system_registers[phase_index()][index];
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpu_destroy(hv_vcpu_t vcpu) {
    (void)vcpu;
    observe_owner_thread(phase_index());
    if (fail_now(TEST_OP_VCPU_DESTROY)) return HV_ERROR;
    fake_vcpu_live[phase_index()] = false;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vm_unmap(hv_ipa_t ipa, size_t length) {
    int region = region_index(ipa);
    if (region < 0 || length != slot_size) return HV_BAD_ARGUMENT;
    if (fail_now(TEST_OP_UNMAP)) return HV_ERROR;
    mapped_pages[phase_index()][region] = NULL;
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vm_destroy(void) {
    if (fail_now(TEST_OP_VM_DESTROY)) return HV_ERROR;
    int index = phase_index();
    fake_vm_live[index] = false;
    memset(mapped_pages[index], 0, sizeof(mapped_pages[index]));
    return HV_SUCCESS;
}

hv_return_t h3_test_hv_vcpus_exit(hv_vcpu_t *vcpus, uint32_t count) {
    if (!vcpus || count != 1 || *vcpus != lifetime.vcpu) return HV_BAD_ARGUMENT;
    pthread_mutex_lock(&exit_event_lock);
    atomic_fetch_add_explicit(&exit_calls, 1, memory_order_seq_cst);
    pthread_cond_broadcast(&exit_event_condition);
    pthread_mutex_unlock(&exit_event_lock);
    return HV_SUCCESS;
}

static void reset_test_state(void) {
    memset(&configuration, 0, sizeof(configuration));
    current_phase = test_phase_source;
    memset(calls, 0, sizeof(calls));
    memset(vm_create_calls, 0, sizeof(vm_create_calls));
    memset(run_calls, 0, sizeof(run_calls));
    memset(successful_host_unmaps, 0, sizeof(successful_host_unmaps));
    atomic_store_explicit(&exit_calls, 0, memory_order_seq_cst);
    ordering_violations = 0;
    source_conserved_before_target = false;
    memset(owner_thread, 0, sizeof(owner_thread));
    memset(owner_thread_set, 0, sizeof(owner_thread_set));
    owner_thread_mismatch = false;
    memset(exits, 0, sizeof(exits));
    memset(registers, 0, sizeof(registers));
    memset(system_registers, 0, sizeof(system_registers));
    memset(mapped_pages, 0, sizeof(mapped_pages));
    memset(fake_vm_live, 0, sizeof(fake_vm_live));
    memset(fake_vcpu_live, 0, sizeof(fake_vcpu_live));
    memset(allocation_in_use, 0, sizeof(allocation_in_use));
    atomic_store_explicit(&force_deadline_elapsed, false, memory_order_seq_cst);
    atomic_store_explicit(&ui_watchdog_race_release, false, memory_order_seq_cst);
    atomic_store_explicit(&real_watchdog_started, 0, memory_order_seq_cst);
    atomic_store_explicit(&real_watchdog_exited, 0, memory_order_seq_cst);
    memset(real_watchdog_starts, 0, sizeof(real_watchdog_starts));
    memset(&lifetime, 0, sizeof(lifetime));
    memset(h3_watchdog_slots, 0, sizeof(h3_watchdog_slots));
}

static int reserve(EPRGuestReservation **token) {
    int error = 0;
    *token = epr_guest_reserve(&error);
    CHECK(*token && error == 0);
    configuration.token = *token;
    return 0;
}

static int release(EPRGuestReservation *token) {
    CHECK(epr_guest_reservation_release(token) == 0);
    return 0;
}

static int exact_checkpoint_diagnostic(const EPRGuestH3CursorResumeResult *result) {
    const EPRGuestH3CheckpointDiagnostic *diagnostic = &result->checkpoint_diagnostic;
    CHECK(result->abi_version == 5 && diagnostic->schema_version == 1);
    CHECK(diagnostic->required_mask == EPR_GUEST_H3_CP_REQUIRED_MASK &&
          diagnostic->evaluated_mask == EPR_GUEST_H3_CP_REQUIRED_MASK &&
          diagnostic->passed_mask == EPR_GUEST_H3_CP_REQUIRED_MASK);
    CHECK(diagnostic->gpr_mismatch_mask == 0 && diagnostic->reserved_zero == 0 &&
          diagnostic->checkpoint_sequence == 1);
    for (size_t i = 0; i < h3_gpr_count; ++i)
        CHECK(diagnostic->gprs[i] == h3_expected_checkpoint_gpr(i));
    CHECK(diagnostic->cpsr == UINT64_C(0x600003c5) &&
          diagnostic->sctlr == initial_sctlr && diagnostic->sp == h3_stack_top &&
          diagnostic->vbar == 0);
    for (size_t i = 0; i < EPR_GUEST_H3_CP_PAGE_COUNT; ++i) {
        const EPRGuestH3PageMismatchWitness *witness = &diagnostic->page_witnesses[i];
        CHECK(witness->first_mismatch_offset == UINT32_MAX &&
              witness->observed_byte == 0 && witness->expected_byte == 0 &&
              witness->reserved_zero == 0);
    }
    return 0;
}

static int exact_sctlr_transition_diagnostic(
    const EPRGuestH3CursorResumeResult *result, uint32_t schema_version,
    uint32_t sampled_mask, uint64_t requested,
    uint32_t pre_entries, int32_t pre_status, uint64_t pre_value,
    uint32_t post_entries, int32_t post_status, uint64_t post_value) {
    const EPRGuestH3SCTLRTransitionDiagnostic *diagnostic =
        &result->sctlr_transition_diagnostic;
    CHECK(diagnostic->schema_version == schema_version &&
          diagnostic->sampled_mask == sampled_mask &&
          diagnostic->source_pre_entry_read_entries == pre_entries &&
          diagnostic->source_post_exit_read_entries == post_entries &&
          diagnostic->source_pre_entry_read_status == pre_status &&
          diagnostic->source_post_exit_read_status == post_status &&
          diagnostic->reserved_zero_0 == 0 && diagnostic->reserved_zero_1 == 0 &&
          diagnostic->requested == requested &&
          diagnostic->source_pre_entry == pre_value &&
          diagnostic->source_post_exit == post_value);
    return 0;
}

static int sctlr_transition_layout(void) {
    CHECK(EPR_GUEST_H3_SCTLR_REQUIRED_MASK == UINT32_C(0x7));
    CHECK(offsetof(EPRGuestH3SCTLRTransitionDiagnostic, schema_version) == 0 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, sampled_mask) == 4 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                   source_pre_entry_read_entries) == 8 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                   source_post_exit_read_entries) == 12 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                   source_pre_entry_read_status) == 16 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                   source_post_exit_read_status) == 20 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, reserved_zero_0) == 24 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, reserved_zero_1) == 28 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, requested) == 32 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, source_pre_entry) == 40 &&
          offsetof(EPRGuestH3SCTLRTransitionDiagnostic, source_post_exit) == 48 &&
          sizeof(EPRGuestH3SCTLRTransitionDiagnostic) == 56 &&
          offsetof(EPRGuestH3CursorResumeResult, checkpoint_diagnostic) == 1296 &&
          offsetof(EPRGuestH3CursorResumeResult, sctlr_transition_diagnostic) == 1632 &&
          sizeof(EPRGuestH3CursorResumeResult) == 1688);
    return 0;
}

static int pass_path(void) {
    reset_test_state();
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(result.outcome == EPR_GUEST_PASS && result.execution_pass == 1 &&
          result.teardown_pass == 1 && result.resources_quarantined == 0);
    CHECK(result.source.generation > 0 && (result.source.generation & 1) == 1 &&
          result.target.generation == result.source.generation + 1);
    CHECK(result.watchdog_create_entries == 2 && result.watchdog_join_entries == 2);
    CHECK(result.source.run_entries == 1 && result.target.run_entries == 1 &&
          result.source.conserved == 1 && result.target.conserved == 1);
    CHECK(result.source.register_set_calls == 36 && result.source.register_read_calls == 36 &&
          result.target.register_set_calls == 36 && result.target.register_read_calls == 38);
    CHECK(exact_checkpoint_diagnostic(&result) == 0);
    CHECK(exact_sctlr_transition_diagnostic(
              &result, 1, EPR_GUEST_H3_SCTLR_REQUIRED_MASK, initial_sctlr,
              1, HV_SUCCESS, initial_sctlr, 1, HV_SUCCESS, initial_sctlr) == 0);
    CHECK(result.sctlr_transition_diagnostic.source_post_exit ==
          result.checkpoint_diagnostic.sctlr);
    CHECK(source_conserved_before_target && ordering_violations == 0);
    CHECK(vm_create_calls[0] == 1 && vm_create_calls[1] == 1 &&
          run_calls[0] == 1 && run_calls[1] == 1);
    for (int phase = 0; phase < 2; ++phase) {
        CHECK(calls[phase][TEST_OP_ALLOCATE] == 3);
        CHECK(calls[phase][TEST_OP_VM_CREATE] == 1);
        CHECK(calls[phase][TEST_OP_MAP] == 3);
        CHECK(calls[phase][TEST_OP_VCPU_CREATE] == 1);
        CHECK(calls[phase][TEST_OP_REGISTER] == 36);
        CHECK(calls[phase][TEST_OP_WATCHDOG_CREATE] == 1);
        CHECK(calls[phase][TEST_OP_RUN] == 1);
        CHECK(calls[phase][TEST_OP_WATCHDOG_JOIN] == 1);
        CHECK(calls[phase][TEST_OP_VCPU_DESTROY] == 1);
        CHECK(calls[phase][TEST_OP_UNMAP] == 3);
        CHECK(calls[phase][TEST_OP_VM_DESTROY] == 1);
        CHECK(calls[phase][TEST_OP_HOST_UNMAP] == 3);
    }
    CHECK(calls[0][TEST_OP_READ] == 35 &&
          calls[0][TEST_OP_SOURCE_PRE_ENTRY_SCTLR_READ] == 1 &&
          calls[0][TEST_OP_SOURCE_POST_EXIT_SCTLR_READ] == 1 &&
          calls[0][TEST_OP_TERMINAL_READ] == 0);
    CHECK(calls[1][TEST_OP_READ] == 36 &&
          calls[1][TEST_OP_TERMINAL_READ] == 2);
    CHECK(owner_thread_set[0] && owner_thread_set[1] && !owner_thread_mismatch);
    CHECK(exit_calls == 0);
    CHECK(all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static int sctlr_transition_value_localization(void) {
    const uint64_t canonicalized = initial_sctlr | UINT64_C(0x180);

    /* The native checkpoint predicate is intentionally unchanged: an immediate
     * canonical value that remains stable through the run still fails SCTLR. */
    reset_test_state();
    configuration.source_pre_entry_sctlr_override = true;
    configuration.source_pre_entry_sctlr = canonicalized;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult normalized =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(normalized.outcome == EPR_GUEST_FAILED &&
          normalized.failure_stage == stage_predicates &&
          normalized.first_error == EPROTO && normalized.source.run_entries == 1 &&
          normalized.target.run_entries == 0 && normalized.teardown_pass == 1);
    CHECK(normalized.checkpoint_diagnostic.evaluated_mask ==
              EPR_GUEST_H3_CP_REQUIRED_MASK &&
          normalized.checkpoint_diagnostic.passed_mask ==
              (EPR_GUEST_H3_CP_REQUIRED_MASK & ~EPR_GUEST_H3_CP_SCTLR) &&
          normalized.checkpoint_diagnostic.sctlr == canonicalized);
    CHECK(exact_sctlr_transition_diagnostic(
              &normalized, 1, EPR_GUEST_H3_SCTLR_REQUIRED_MASK, initial_sctlr,
              1, HV_SUCCESS, canonicalized,
              1, HV_SUCCESS, canonicalized) == 0);
    CHECK(release(token) == 0);

    /* A value changed only after entry is independently localized to the
     * post-exit sample and remains joined to the checkpoint witness. */
    reset_test_state();
    configuration.source_post_exit_sctlr_override = true;
    configuration.source_post_exit_sctlr = canonicalized;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult post_delta =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(post_delta.outcome == EPR_GUEST_FAILED &&
          post_delta.failure_stage == stage_predicates &&
          post_delta.first_error == EPROTO && post_delta.source.run_entries == 1 &&
          post_delta.target.run_entries == 0 && post_delta.teardown_pass == 1);
    CHECK(post_delta.checkpoint_diagnostic.evaluated_mask ==
              EPR_GUEST_H3_CP_REQUIRED_MASK &&
          post_delta.checkpoint_diagnostic.passed_mask ==
              (EPR_GUEST_H3_CP_REQUIRED_MASK & ~EPR_GUEST_H3_CP_SCTLR) &&
          post_delta.checkpoint_diagnostic.sctlr == canonicalized);
    CHECK(exact_sctlr_transition_diagnostic(
              &post_delta, 1, EPR_GUEST_H3_SCTLR_REQUIRED_MASK, initial_sctlr,
              1, HV_SUCCESS, initial_sctlr,
              1, HV_SUCCESS, canonicalized) == 0);
    CHECK(post_delta.sctlr_transition_diagnostic.source_post_exit ==
          post_delta.checkpoint_diagnostic.sctlr);
    CHECK(release(token) == 0);
    return 0;
}

static int sctlr_transition_partial_and_read_failures(void) {
    EPRGuestReservation *token;

    reset_test_state();
    configuration.fault_phase = test_phase_source;
    configuration.fault_operation = TEST_OP_ALLOCATE;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult sentinel =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(sentinel.failure_stage == stage_memory && sentinel.source.run_entries == 0);
    CHECK(exact_sctlr_transition_diagnostic(
              &sentinel, 0, 0, 0,
              0, 0, 0, 0, 0, 0) == 0);
    CHECK(release(token) == 0);

    reset_test_state();
    configuration.fault_phase = test_phase_source;
    configuration.fault_operation = TEST_OP_SOURCE_PRE_ENTRY_SCTLR_READ;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult pre_error =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(configuration.fault_consumed && pre_error.outcome == EPR_GUEST_FAILED &&
          pre_error.failure_stage == stage_registers && pre_error.first_error == HV_ERROR &&
          pre_error.source.register_set_calls == 36 &&
          pre_error.source.register_read_calls == 0 &&
          pre_error.source.run_entries == 0 && pre_error.target.run_entries == 0 &&
          pre_error.teardown_pass == 1 && pre_error.source_conserved == 1);
    CHECK(exact_sctlr_transition_diagnostic(
              &pre_error, 1, EPR_GUEST_H3_SCTLR_REQUESTED, initial_sctlr,
              1, HV_ERROR, 0, 0, INT32_MIN, 0) == 0);
    CHECK(release(token) == 0);

    reset_test_state();
    configuration.fault_phase = test_phase_source;
    configuration.fault_operation = TEST_OP_SOURCE_POST_EXIT_SCTLR_READ;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult post_error =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(configuration.fault_consumed && post_error.outcome == EPR_GUEST_FAILED &&
          post_error.failure_stage == stage_exit_registers &&
          post_error.first_error == HV_ERROR && post_error.source.run_entries == 1 &&
          post_error.source.register_read_calls == 1 &&
          post_error.target.run_entries == 0 && post_error.teardown_pass == 1 &&
          post_error.source_conserved == 1 &&
          post_error.checkpoint_diagnostic.evaluated_mask == 0);
    CHECK(exact_sctlr_transition_diagnostic(
              &post_error, 1,
              EPR_GUEST_H3_SCTLR_REQUESTED | EPR_GUEST_H3_SCTLR_SOURCE_PRE_ENTRY,
              initial_sctlr,
              1, HV_SUCCESS, initial_sctlr, 1, HV_ERROR, 0) == 0);
    CHECK(release(token) == 0);
    return 0;
}

typedef struct {
    uint32_t injected_mask;
    uint32_t cleared_mask;
    int page_index;
    uint32_t mismatch_offset;
    uint8_t observed_byte;
    uint8_t expected_byte;
    uint32_t gpr_mismatch_mask;
} CheckpointFaultCase;

static int checkpoint_fault_case(const CheckpointFaultCase *test) {
    reset_test_state();
    configuration.checkpoint_fault_mask = test->injected_mask;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    const EPRGuestH3CheckpointDiagnostic *diagnostic = &result.checkpoint_diagnostic;
    CHECK(result.abi_version == 5 && result.outcome == EPR_GUEST_FAILED &&
          result.execution_pass == 0 && result.failure_stage == stage_predicates &&
          result.first_error == EPROTO);
    CHECK(result.teardown_pass == 1 && result.resources_quarantined == 0 &&
          result.source.run_entries == 1 && result.source.conserved == 1 &&
          result.source_conserved == 1 && result.target.run_entries == 0 &&
          result.target.vm_create_status == INT32_MIN && result.target_conserved == 0);
    CHECK(diagnostic->schema_version == 1 &&
          diagnostic->required_mask == EPR_GUEST_H3_CP_REQUIRED_MASK &&
          diagnostic->evaluated_mask == EPR_GUEST_H3_CP_REQUIRED_MASK &&
          diagnostic->passed_mask ==
              (EPR_GUEST_H3_CP_REQUIRED_MASK & ~test->cleared_mask));
    CHECK(diagnostic->gpr_mismatch_mask == test->gpr_mismatch_mask &&
          !(diagnostic->gpr_mismatch_mask & (UINT32_C(1) << 31)) &&
          diagnostic->reserved_zero == 0);
    for (int page = 0; page < EPR_GUEST_H3_CP_PAGE_COUNT; ++page) {
        const EPRGuestH3PageMismatchWitness *witness =
            &diagnostic->page_witnesses[page];
        bool request_mismatch = page == EPR_GUEST_H3_CP_PAGE_REQUEST &&
            (test->injected_mask & EPR_GUEST_H3_CP_REQUEST_PAGE);
        bool reply_sequence_mismatch = page == EPR_GUEST_H3_CP_PAGE_REPLY &&
            (test->injected_mask & EPR_GUEST_H3_CP_SEQUENCE);
        if (request_mismatch) {
            CHECK(witness->first_mismatch_offset == sizeof(expected_request) &&
                  witness->observed_byte == UINT8_C(0xb2) && witness->expected_byte == 0);
        } else if (reply_sequence_mismatch) {
            CHECK(witness->first_mismatch_offset == 0 &&
                  witness->observed_byte == 9 && witness->expected_byte == 1);
        } else if (page == test->page_index) {
            CHECK(witness->first_mismatch_offset == test->mismatch_offset &&
                  witness->observed_byte == test->observed_byte &&
                  witness->expected_byte == test->expected_byte);
        } else {
            CHECK(witness->first_mismatch_offset == UINT32_MAX &&
                  witness->observed_byte == 0 && witness->expected_byte == 0);
        }
        CHECK(witness->reserved_zero == 0);
    }
    if (test->injected_mask & EPR_GUEST_H3_CP_SEQUENCE)
        CHECK(diagnostic->checkpoint_sequence == 9);
    else CHECK(diagnostic->checkpoint_sequence == 1);
    if (test->injected_mask & EPR_GUEST_H3_CP_GPRS) {
        size_t changed = 6;
        for (size_t i = 0; i < h3_gpr_count; ++i)
            CHECK(diagnostic->gprs[i] ==
                  (h3_expected_checkpoint_gpr(i) ^ (uint64_t)(i == changed)));
    }
    if (test->injected_mask & EPR_GUEST_H3_CP_CPSR)
        CHECK(diagnostic->cpsr == (UINT64_C(0x600003c5) ^ (UINT64_C(1) << 28)));
    if (test->injected_mask & EPR_GUEST_H3_CP_SCTLR)
        CHECK(diagnostic->sctlr == (initial_sctlr ^ 1));
    CHECK(result.sctlr_transition_diagnostic.sampled_mask ==
              EPR_GUEST_H3_SCTLR_REQUIRED_MASK &&
          result.sctlr_transition_diagnostic.source_pre_entry == initial_sctlr &&
          result.sctlr_transition_diagnostic.source_post_exit == diagnostic->sctlr);
    if (test->injected_mask & EPR_GUEST_H3_CP_SP)
        CHECK(diagnostic->sp == h3_stack_top - 16);
    if (test->injected_mask & EPR_GUEST_H3_CP_VBAR)
        CHECK(diagnostic->vbar == UINT64_C(0x10000000));
    CHECK(vm_create_calls[0] == 1 && vm_create_calls[1] == 0 &&
          run_calls[0] == 1 && run_calls[1] == 0 && all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static int checkpoint_fault_matrix(void) {
    static const CheckpointFaultCase cases[] = {
        { EPR_GUEST_H3_CP_SEQUENCE,
          EPR_GUEST_H3_CP_SEQUENCE | EPR_GUEST_H3_CP_REPLY_PAGE,
          EPR_GUEST_H3_CP_PAGE_REPLY, 0, 9, 1, 0 },
        { EPR_GUEST_H3_CP_CODE_PAGE, EPR_GUEST_H3_CP_CODE_PAGE,
          EPR_GUEST_H3_CP_PAGE_CODE, sizeof(h3_guest_image), UINT8_C(0xa1), 0, 0 },
        { EPR_GUEST_H3_CP_REQUEST_PAGE, EPR_GUEST_H3_CP_REQUEST_PAGE,
          EPR_GUEST_H3_CP_PAGE_REQUEST, sizeof(expected_request), UINT8_C(0xb2), 0, 0 },
        { EPR_GUEST_H3_CP_REPLY_PAGE, EPR_GUEST_H3_CP_REPLY_PAGE,
          EPR_GUEST_H3_CP_PAGE_REPLY, 24, UINT8_C(0xc3), 0, 0 },
        { EPR_GUEST_H3_CP_GPRS, EPR_GUEST_H3_CP_GPRS,
          -1, 0, 0, 0, UINT32_C(1) << 6 },
        { EPR_GUEST_H3_CP_CPSR, EPR_GUEST_H3_CP_CPSR, -1, 0, 0, 0, 0 },
        { EPR_GUEST_H3_CP_SCTLR, EPR_GUEST_H3_CP_SCTLR, -1, 0, 0, 0, 0 },
        { EPR_GUEST_H3_CP_SP, EPR_GUEST_H3_CP_SP, -1, 0, 0, 0, 0 },
        { EPR_GUEST_H3_CP_VBAR, EPR_GUEST_H3_CP_VBAR, -1, 0, 0, 0, 0 },
    };
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i)
        CHECK(checkpoint_fault_case(&cases[i]) == 0);

    const CheckpointFaultCase multiple = {
        EPR_GUEST_H3_CP_SEQUENCE | EPR_GUEST_H3_CP_REQUEST_PAGE |
            EPR_GUEST_H3_CP_GPRS | EPR_GUEST_H3_CP_CPSR,
        EPR_GUEST_H3_CP_SEQUENCE | EPR_GUEST_H3_CP_REQUEST_PAGE |
            EPR_GUEST_H3_CP_REPLY_PAGE | EPR_GUEST_H3_CP_GPRS |
            EPR_GUEST_H3_CP_CPSR,
        EPR_GUEST_H3_CP_PAGE_REPLY, 0, 9, 1, UINT32_C(1) << 6
    };
    CHECK(checkpoint_fault_case(&multiple) == 0);
    return 0;
}

static int checkpoint_gpr_bit_matrix(void) {
    _Alignas(8) unsigned char storage[EPR_GUEST_H3_CP_PAGE_COUNT][slot_size] = {{0}};
    unsigned char *pages[EPR_GUEST_H3_CP_PAGE_COUNT] = {
        storage[EPR_GUEST_H3_CP_PAGE_CODE],
        storage[EPR_GUEST_H3_CP_PAGE_REQUEST],
        storage[EPR_GUEST_H3_CP_PAGE_REPLY]
    };
    memcpy(pages[EPR_GUEST_H3_CP_PAGE_CODE], h3_guest_image, sizeof(h3_guest_image));
    memcpy(pages[EPR_GUEST_H3_CP_PAGE_REQUEST], expected_request, sizeof(expected_request));
    memcpy(pages[EPR_GUEST_H3_CP_PAGE_REPLY], expected_reply, sizeof(expected_reply));
    atomic_store_explicit((_Atomic(uint64_t) *)pages[EPR_GUEST_H3_CP_PAGE_REPLY],
                          1, memory_order_release);

    for (size_t changed = 0; changed < h3_gpr_count; ++changed) {
        uint64_t gprs[h3_gpr_count];
        for (size_t i = 0; i < h3_gpr_count; ++i)
            gprs[i] = h3_expected_checkpoint_gpr(i);
        gprs[changed] ^= 1;
        EPRGuestH3CursorResumeResult result = h3_empty_result();
        h3_capture_checkpoint_diagnostic(&result, pages, gprs,
            UINT64_C(0x600003c5), initial_sctlr, h3_stack_top, 0);
        const EPRGuestH3CheckpointDiagnostic *diagnostic = &result.checkpoint_diagnostic;
        CHECK(diagnostic->evaluated_mask == EPR_GUEST_H3_CP_REQUIRED_MASK &&
              diagnostic->passed_mask ==
                  (EPR_GUEST_H3_CP_REQUIRED_MASK & ~EPR_GUEST_H3_CP_GPRS) &&
              diagnostic->gpr_mismatch_mask == (UINT32_C(1) << changed));
        for (size_t i = 0; i < h3_gpr_count; ++i)
            CHECK(diagnostic->gprs[i] ==
                  (h3_expected_checkpoint_gpr(i) ^ (uint64_t)(i == changed)));
    }
    return 0;
}

static int checkpoint_not_evaluated_paths(void) {
    reset_test_state();
    configuration.fault_phase = test_phase_source;
    configuration.fault_operation = TEST_OP_RUN;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult before =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(before.failure_stage == stage_run &&
          before.checkpoint_diagnostic.evaluated_mask == 0 &&
          before.checkpoint_diagnostic.passed_mask == 0 &&
          before.checkpoint_diagnostic.required_mask == EPR_GUEST_H3_CP_REQUIRED_MASK);
    CHECK(release(token) == 0);

    reset_test_state();
    configuration.checkpoint_fault_mask = TEST_CHECKPOINT_TRAP;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult trap =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(trap.failure_stage == stage_predicates && trap.first_error == EPROTO &&
          trap.checkpoint_diagnostic.evaluated_mask == 0 &&
          trap.checkpoint_diagnostic.passed_mask == 0 &&
          trap.source.run_entries == 1 && trap.source.conserved == 1 &&
          trap.target.run_entries == 0 && trap.teardown_pass == 1 &&
          trap.resources_quarantined == 0 && all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static bool cleanup_fault(TestOperation operation) {
    return operation == TEST_OP_WATCHDOG_JOIN ||
        operation == TEST_OP_VCPU_DESTROY || operation == TEST_OP_UNMAP ||
        operation == TEST_OP_VM_DESTROY || operation == TEST_OP_HOST_UNMAP;
}

static int fault_path(int phase, TestOperation operation) {
    reset_test_state();
    configuration.fault_phase = phase;
    configuration.fault_operation = operation;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(configuration.fault_consumed);
    if (result.outcome == EPR_GUEST_PASS ||
        (result.execution_pass && result.teardown_pass))
        fprintf(stderr, "fault phase=%d operation=%d outcome=%u execution=%u teardown=%u stage=%d error=%d\n",
                phase, operation, result.outcome, result.execution_pass,
                result.teardown_pass, result.failure_stage, result.first_error);
    CHECK(result.outcome != EPR_GUEST_PASS &&
          !(result.execution_pass && result.teardown_pass));
    CHECK(calls[phase - 1][operation] >= 1);
    if (phase == test_phase_source && operation == TEST_OP_READ) {
        CHECK(result.source.run_entries == 1 &&
              result.source.register_read_calls == 2 &&
              result.sctlr_transition_diagnostic.sampled_mask ==
                  EPR_GUEST_H3_SCTLR_REQUIRED_MASK &&
              result.sctlr_transition_diagnostic.source_post_exit_read_entries == 1 &&
              result.sctlr_transition_diagnostic.source_post_exit_read_status == HV_SUCCESS &&
              result.sctlr_transition_diagnostic.source_post_exit == initial_sctlr &&
              result.checkpoint_diagnostic.evaluated_mask == 0);
    }
    CHECK(exit_calls <= 1 && ordering_violations == 0 && !owner_thread_mismatch);
    if (phase == test_phase_source) CHECK(vm_create_calls[1] == 0);
    if (cleanup_fault(operation)) CHECK(result.resources_quarantined == 1);
    else CHECK(result.resources_quarantined == 0);
    CHECK(release(token) == 0);
    return 0;
}

static int fault_matrix(void) {
    static const TestOperation operations[] = {
        TEST_OP_ALLOCATE, TEST_OP_VM_CREATE, TEST_OP_MAP,
        TEST_OP_VCPU_CREATE, TEST_OP_REGISTER, TEST_OP_WATCHDOG_CREATE,
        TEST_OP_RUN, TEST_OP_READ, TEST_OP_WATCHDOG_JOIN,
        TEST_OP_VCPU_DESTROY, TEST_OP_UNMAP, TEST_OP_VM_DESTROY,
        TEST_OP_HOST_UNMAP
    };
    for (int phase = test_phase_source; phase <= test_phase_target; ++phase) {
        for (size_t i = 0; i < sizeof(operations) / sizeof(operations[0]); ++i)
            CHECK(fault_path(phase, operations[i]) == 0);
    }
    CHECK(fault_path(test_phase_target, TEST_OP_TERMINAL_READ) == 0);
    return 0;
}

static int cancellation_path(TestCancellation cancellation) {
    reset_test_state();
    configuration.cancellation = cancellation;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    if (cancellation == TEST_CANCEL_PRE_SETUP)
        epr_guest_reservation_request_cancel(token);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(result.outcome == EPR_GUEST_CANCELED && result.execution_pass == 0);
    CHECK(result.cancellation_requested == 1 && exit_calls <= 1);
    CHECK(ordering_violations == 0 && !owner_thread_mismatch);
    if (cancellation == TEST_CANCEL_PRE_SETUP) {
        CHECK(vm_create_calls[0] == 0 && vm_create_calls[1] == 0 && exit_calls == 0);
    } else if (cancellation == TEST_CANCEL_SOURCE_RUN) {
        CHECK(run_calls[0] == 1 && vm_create_calls[1] == 0 && exit_calls == 1);
    } else if (cancellation == TEST_CANCEL_BETWEEN_PHASES) {
        CHECK(source_conserved_before_target && vm_create_calls[1] == 0 && exit_calls == 0);
    } else {
        CHECK(source_conserved_before_target && run_calls[1] == 1 && exit_calls == 1);
    }
    CHECK(release(token) == 0);
    return 0;
}

static int cancellation_matrix(void) {
    CHECK(cancellation_path(TEST_CANCEL_PRE_SETUP) == 0);
    CHECK(cancellation_path(TEST_CANCEL_SOURCE_RUN) == 0);
    CHECK(cancellation_path(TEST_CANCEL_BETWEEN_PHASES) == 0);
    CHECK(cancellation_path(TEST_CANCEL_TARGET_RUN) == 0);
    return 0;
}

static int real_watchdog_success_and_join_races(void) {
    enum { iterations = 32 };
    for (int iteration = 0; iteration < iterations; ++iteration) {
        reset_test_state();
        configuration.real_watchdog_threads = true;
        EPRGuestReservation *token;
        CHECK(reserve(&token) == 0);
        EPRGuestH3CursorResumeResult result =
            epr_guest_h3_cursor_resume_run_reserved(token);
        CHECK(result.outcome == EPR_GUEST_PASS && result.watchdog_fired == 0);
        CHECK(result.teardown_pass == 1 && result.resources_quarantined == 0);
        CHECK(result.source_conserved == 1 && result.target_conserved == 1 &&
              result.source.conserved == 1 && result.target.conserved == 1);
        CHECK(result.watchdog_create_entries == 2 && result.watchdog_join_entries == 2);
        CHECK(atomic_load_explicit(&real_watchdog_started, memory_order_seq_cst) == 2);
        CHECK(atomic_load_explicit(&real_watchdog_exited, memory_order_seq_cst) == 2);
        CHECK(atomic_load_explicit(&exit_calls, memory_order_seq_cst) == 0);
        CHECK(all_fake_resources_gone());
        CHECK(release(token) == 0);
    }
    return 0;
}

static int published_vcpu_pre_run_cancellation(void) {
    reset_test_state();
    configuration.real_watchdog_threads = true;
    configuration.cancellation = TEST_CANCEL_PRE_SOURCE_RUN;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(result.outcome == EPR_GUEST_CANCELED && result.cancellation_requested == 1);
    CHECK(result.teardown_pass == 1 && result.resources_quarantined == 0);
    CHECK(result.source_conserved == 1 && result.source.conserved == 1 &&
          result.target_conserved == 0 && result.target.conserved == 0);
    CHECK(result.source.run_entries == 0 && result.target.run_entries == 0);
    CHECK(atomic_load_explicit(&exit_calls, memory_order_seq_cst) == 1);
    CHECK(result.cancellation_calls == 1 && result.watchdog_create_entries == 1 &&
          result.watchdog_join_entries == 1);
    CHECK(atomic_load_explicit(&real_watchdog_started, memory_order_seq_cst) == 1);
    CHECK(atomic_load_explicit(&real_watchdog_exited, memory_order_seq_cst) == 1);
    CHECK(all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static int concurrent_run_cancellation(bool target_phase) {
    reset_test_state();
    configuration.real_watchdog_threads = true;
    configuration.cancellation = target_phase ?
        TEST_CANCEL_TARGET_RUN_CONCURRENT : TEST_CANCEL_SOURCE_RUN_CONCURRENT;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(result.outcome == EPR_GUEST_CANCELED && result.cancellation_requested == 1);
    CHECK(result.teardown_pass == 1 && result.resources_quarantined == 0);
    CHECK(atomic_load_explicit(&exit_calls, memory_order_seq_cst) == 1);
    CHECK(result.cancellation_calls == 1);
    if (target_phase) {
        CHECK(result.source_conserved == 1 && result.target_conserved == 1 &&
              result.source.conserved == 1 && result.target.conserved == 1);
        CHECK(result.source.run_entries == 1 && result.target.run_entries == 1);
        CHECK(result.watchdog_create_entries == 2 && result.watchdog_join_entries == 2);
        CHECK(atomic_load_explicit(&real_watchdog_started, memory_order_seq_cst) == 2);
        CHECK(atomic_load_explicit(&real_watchdog_exited, memory_order_seq_cst) == 2);
    } else {
        CHECK(result.source_conserved == 1 && result.source.conserved == 1 &&
              result.target_conserved == 0 && result.target.conserved == 0);
        CHECK(result.source.run_entries == 1 && result.target.run_entries == 0);
        CHECK(result.watchdog_create_entries == 1 && result.watchdog_join_entries == 1);
        CHECK(atomic_load_explicit(&real_watchdog_started, memory_order_seq_cst) == 1);
        CHECK(atomic_load_explicit(&real_watchdog_exited, memory_order_seq_cst) == 1);
    }
    CHECK(all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static int bounded_watchdog_cancellation(bool race_ui) {
    reset_test_state();
    configuration.real_watchdog_threads = true;
    configuration.bounded_watchdog_timeout = true;
    configuration.cancellation = race_ui ?
        TEST_CANCEL_UI_WATCHDOG_RACE : TEST_CANCEL_WATCHDOG_TIMEOUT;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult result =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(result.outcome == EPR_GUEST_CANCELED && result.watchdog_fired == 1);
    CHECK(result.teardown_pass == 1 && result.resources_quarantined == 0);
    CHECK(result.source_conserved == 1 && result.source.conserved == 1 &&
          result.target_conserved == 0 && result.target.conserved == 0);
    CHECK(result.source.run_entries == 1 && result.target.run_entries == 0);
    CHECK(result.cancellation_requested == 1 && result.cancellation_calls == 1);
    CHECK(atomic_load_explicit(&exit_calls, memory_order_seq_cst) == 1);
    CHECK(result.watchdog_create_entries == 1 && result.watchdog_join_entries == 1);
    CHECK(atomic_load_explicit(&real_watchdog_started, memory_order_seq_cst) == 1);
    CHECK(atomic_load_explicit(&real_watchdog_exited, memory_order_seq_cst) == 1);
    CHECK(all_fake_resources_gone());
    CHECK(release(token) == 0);
    return 0;
}

static int busy_rejection(void) {
    reset_test_state();
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    pthread_mutex_lock(&lifetime_lock);
    lifetime.active = true;
    pthread_mutex_unlock(&lifetime_lock);
    EPRGuestH3CursorResumeResult rejected =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(rejected.outcome == EPR_GUEST_BUSY &&
          rejected.resources_quarantined == 0);
    CHECK(exact_sctlr_transition_diagnostic(
              &rejected, 0, 0, 0, 0, 0, 0, 0, 0, 0) == 0);
    pthread_mutex_lock(&lifetime_lock);
    lifetime.active = false;
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(release(token) == 0);
    return 0;
}

static int sticky_quarantine(void) {
    reset_test_state();
    configuration.fault_phase = test_phase_source;
    configuration.fault_operation = TEST_OP_VCPU_DESTROY;
    EPRGuestReservation *token;
    CHECK(reserve(&token) == 0);
    EPRGuestH3CursorResumeResult failed =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(failed.outcome == EPR_GUEST_FAILED && failed.resources_quarantined == 1);
    unsigned source_creates = vm_create_calls[0];
    EPRGuestH3CursorResumeResult rejected =
        epr_guest_h3_cursor_resume_run_reserved(token);
    CHECK(rejected.outcome == EPR_GUEST_QUARANTINED &&
          rejected.resources_quarantined == 1 && vm_create_calls[0] == source_creates);
    CHECK(exact_sctlr_transition_diagnostic(
              &rejected, 0, 0, 0, 0, 0, 0, 0, 0, 0) == 0);
    CHECK(release(token) == 0);
    int error = 0;
    CHECK(epr_guest_reserve(&error) == NULL && error == EPERM);
    return 0;
}

int main(void) {
    if (sctlr_transition_layout() || pass_path() ||
        sctlr_transition_value_localization() ||
        sctlr_transition_partial_and_read_failures() ||
        checkpoint_fault_matrix() || checkpoint_gpr_bit_matrix() ||
        checkpoint_not_evaluated_paths() ||
        fault_matrix() || cancellation_matrix() ||
        real_watchdog_success_and_join_races() || published_vcpu_pre_run_cancellation() ||
        concurrent_run_cancellation(false) || concurrent_run_cancellation(true) ||
        bounded_watchdog_cancellation(false) || bounded_watchdog_cancellation(true) ||
        busy_rejection() || sticky_quarantine())
        return 1;
    puts("PASS H3 native controller: ABI-v5 SCTLR requested/pre-entry/post-exit snapshot and ABI-v4 nine-bit checkpoint snapshot, stable canonicalization and post-entry delta localization, pre/post read failures and partial sentinels, 9 single-predicate faults, all 31 individual GPR mismatch bits, one multi-fault, pre-checkpoint and trap-first non-evaluation, 1 substituted full path, 27 phase faults, 4 basic cancellation cuts, 32 two-phase real-watchdog passes (64 joins), published-vCPU pre-run cancellation, 2 concurrent UI cancellations, bounded watchdog timeout, UI/watchdog race, BUSY and sticky-quarantine zero-suffix rejection; zero Hypervisor entries");
    return 0;
}
