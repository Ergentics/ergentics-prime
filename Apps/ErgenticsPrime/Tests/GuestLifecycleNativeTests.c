/* Standalone, compile-time no-HV mechanics tests. Compile this translation unit
 * only; it includes the production reservation implementation with real guest
 * bodies excluded and the sole exit request replaced by a counter. It creates
 * pthreads, not processes. No VM, guest, signal, file, network or cleanup action.
 * Example compiler inputs: -std=c11 -Wall -Wextra -Werror -pthread this-file.c
 * No Hypervisor/Security/CommonCrypto framework link is required. */
#define EPR_GUEST_LIFECYCLE_TESTS 1
#include "../Sources/HypervisorGuest.c"
#include <stdio.h>

#define CHECK(value) do { if (!(value)) { \
    fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #value); return 1; \
} } while (0)

static int claim(EPRGuestReservation *reservation) {
    pthread_mutex_lock(&lifetime_lock);
    int result = claim_lifetime_locked(reservation);
    pthread_mutex_unlock(&lifetime_lock);
    return result;
}

static void fake_return(bool conserved) {
    pthread_mutex_lock(&lifetime_lock);
    lifetime.finished = true;
    lifetime.vcpu_live = false;
    lifetime.active = false;
    if (!conserved) lifetime.quarantined = true;
    pthread_mutex_unlock(&lifetime_lock);
}

static int reserve_and_references(void) {
    int error = 123;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && error == 0);
    CHECK(!epr_guest_reservation_is_cancelled(token));
    CHECK(epr_guest_reserve(&error) == NULL && error == EBUSY);
    CHECK(claim(NULL) == EBUSY); // Legacy entry cannot bypass the reservation.
    CHECK(epr_guest_reservation_retain(token) == 0);
    CHECK(epr_guest_reservation_release(token) == 0);
    CHECK(epr_guest_reserve(&error) == NULL && error == EBUSY);
    CHECK(epr_guest_reservation_release(token) == 0);
    CHECK(lifetime.reservation == NULL && !lifetime.active);
    return 0;
}

static int cancel_before_preparation_and_entry(void) {
    int error = 0;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && !error);
    // This same-thread locked test would deadlock if the UI intent API took
    // lifetime_lock or attempted a Hypervisor delivery.
    pthread_mutex_lock(&lifetime_lock);
    epr_guest_reservation_request_cancel(token);
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(epr_guest_reservation_is_cancelled(token));
    CHECK(epr_guest_reservation_cancel(token) == 1);
    CHECK(test_exit_calls == 0);
    CHECK(claim(token) == 0);
    pthread_mutex_lock(&lifetime_lock);
    bool canceled = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(canceled && lifetime.cancel_requested);
    CHECK(!lifetime.vcpu_live && test_exit_calls == 0);
    CHECK(epr_guest_reservation_release(token) == EBUSY);
    fake_return(true);
    CHECK(epr_guest_reservation_cancel(token) == 0);
    CHECK(claim(token) == EALREADY);
    CHECK(epr_guest_reservation_release(token) == 0);
    return 0;
}

static int cancel_during_setup(void) {
    int error = 0;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && !error && claim(token) == 0);
    CHECK(!lifetime.cancel_requested);
    epr_guest_reservation_request_cancel(token);
    // The actual production final commitment predicate observes the atomically
    // published token even before the asynchronous delivery worker has run.
    pthread_mutex_lock(&lifetime_lock);
    bool canceled = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(canceled && test_exit_calls == 0);
    fake_return(true);
    CHECK(epr_guest_reservation_release(token) == 0);
    return 0;
}

static int cancel_after_publication_once(void) {
    int error = 0;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && !error && claim(token) == 0);
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu = 73; lifetime.vcpu_live = true;
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(epr_guest_cancel() == 0); // Unscoped legacy cancellation is excluded.
    CHECK(epr_guest_reservation_cancel(token) == 1);
    CHECK(epr_guest_reservation_cancel(token) == 1);
    CHECK(test_exit_calls == 1 && lifetime.cancel_entered);
    fake_return(true);
    CHECK(epr_guest_reservation_cancel(token) == 0 && test_exit_calls == 1);
    CHECK(epr_guest_reservation_retain(token) == 0);
    CHECK(epr_guest_reservation_release(token) == 0);
    CHECK(epr_guest_reserve(&error) == NULL && error == EBUSY);
    CHECK(epr_guest_reservation_release(token) == 0);
    return 0;
}

static int generation_and_identity_join(void) {
    int error = 0;
    EPRGuestReservation *first = epr_guest_reserve(&error);
    CHECK(first && !error);
    const uint64_t previous = first->generation;
    CHECK(epr_guest_reservation_release(first) == 0);
    EPRGuestReservation *next = epr_guest_reserve(&error);
    CHECK(next && !error && next->generation > previous);
    // A fabricated old-generation object is live test memory, NOT a freed
    // pointer. The public contract never permits a use-after-final-release.
    EPRGuestReservation stale = { .generation = previous, .references = 1 };
    atomic_init(&stale.cancel_requested, false);
    CHECK(epr_guest_reservation_cancel(&stale) == 0);
    CHECK(!epr_guest_reservation_is_cancelled(next));
    CHECK(claim(&stale) == EINVAL);
    CHECK(epr_guest_reservation_retain(&stale) == EINVAL);
    CHECK(epr_guest_reservation_release(&stale) == EINVAL);
    const uint64_t generation = next->generation;
    next->generation = previous; // Explicit test-only corruption of the join.
    CHECK(claim(next) == EINVAL);
    next->generation = generation;
    CHECK(claim(next) == 0);
    CHECK(claim(next) == EBUSY);
    fake_return(true);
    CHECK(claim(next) == EALREADY);
    CHECK(epr_guest_reservation_release(next) == 0);
    return 0;
}

enum { worker_count = 8 };
typedef struct { EPRGuestReservation *token; int result; } Worker;
static void *reserve_worker(void *argument) {
    Worker *worker = argument;
    worker->token = epr_guest_reserve(&worker->result);
    return NULL;
}

static int concurrent_reserve_one_winner(void) {
    Worker workers[worker_count] = {0};
    pthread_t threads[worker_count];
    for (size_t i = 0; i < worker_count; ++i)
        CHECK(pthread_create(&threads[i], NULL, reserve_worker, &workers[i]) == 0);
    for (size_t i = 0; i < worker_count; ++i) CHECK(pthread_join(threads[i], NULL) == 0);
    unsigned winners = 0;
    for (size_t i = 0; i < worker_count; ++i) {
        if (workers[i].token) {
            ++winners;
            CHECK(workers[i].result == 0);
            CHECK(epr_guest_reservation_release(workers[i].token) == 0);
        } else CHECK(workers[i].result == EBUSY);
    }
    CHECK(winners == 1);
    return 0;
}

static void *cancel_worker(void *argument) {
    Worker *worker = argument;
    epr_guest_reservation_request_cancel(worker->token);
    worker->result = epr_guest_reservation_cancel(worker->token);
    if (epr_guest_reservation_release(worker->token)) worker->result = -1;
    return NULL;
}

static int concurrent_cancel_one_delivery(void) {
    int error = 0;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && !error && claim(token) == 0);
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu = 74; lifetime.vcpu_live = true;
    unsigned before = test_exit_calls;
    pthread_mutex_unlock(&lifetime_lock);
    Worker workers[worker_count] = {0};
    pthread_t threads[worker_count];
    for (size_t i = 0; i < worker_count; ++i) {
        CHECK(epr_guest_reservation_retain(token) == 0);
        workers[i].token = token;
        CHECK(pthread_create(&threads[i], NULL, cancel_worker, &workers[i]) == 0);
    }
    for (size_t i = 0; i < worker_count; ++i) {
        CHECK(pthread_join(threads[i], NULL) == 0);
        CHECK(workers[i].result == 1);
    }
    CHECK(test_exit_calls == before + 1);
    fake_return(true);
    CHECK(epr_guest_reservation_release(token) == 0);
    return 0;
}

static int failed_delivery_and_quarantine(void) {
    int error = 0;
    EPRGuestReservation *token = epr_guest_reserve(&error);
    CHECK(token && !error && claim(token) == 0);
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu = 75; lifetime.vcpu_live = true;
    test_exit_status = -123;
    unsigned before = test_exit_calls;
    pthread_mutex_unlock(&lifetime_lock);
    CHECK(epr_guest_reservation_cancel(token) == 1);
    CHECK(epr_guest_reservation_cancel(token) == 1);
    CHECK(test_exit_calls == before + 1 && lifetime.cancel_status == -123);
    fake_return(false);
    CHECK(epr_guest_reservation_release(token) == 0);
    CHECK(epr_guest_reserve(&error) == NULL && error == EPERM);
    CHECK(claim(NULL) == EPERM);
    return 0;
}

int main(void) {
    int (*const tests[])(void) = {
        reserve_and_references, cancel_before_preparation_and_entry,
        cancel_during_setup, cancel_after_publication_once,
        generation_and_identity_join, concurrent_reserve_one_winner,
        concurrent_cancel_one_delivery, failed_delivery_and_quarantine
    };
    for (size_t i = 0; i < sizeof(tests) / sizeof(tests[0]); ++i)
        if (tests[i]()) return 1;
    puts("PASS 8 native reservation lifecycle groups; stubbed exit delivery; zero VM/guest/process/signal/file operations");
    return 0;
}
