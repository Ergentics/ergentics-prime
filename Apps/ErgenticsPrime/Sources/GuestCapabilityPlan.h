#ifndef ERGENTICS_PRIVATE_GUEST_CAPABILITY_PLAN_H
#define ERGENTICS_PRIVATE_GUEST_CAPABILITY_PLAN_H
/* Private, allocation-free fixed-profile primitive. No loader, environment,
 * host namespace or public execution API. A plan is data until the native
 * lifetime owner admits it; deserializing a witness can never admit a run. */
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <limits.h>
#include <string.h>

enum { cap_slot_bytes = 16384, cap_max_regions = 4 };
typedef struct {
    uint64_t object, ipa, length, rights;
} EPRCapRegion;
typedef struct {
    uint64_t version, profile, generation, count;
    EPRCapRegion regions[cap_max_regions];
    uint64_t endpoint, pc, width, value, stack_top;
    /* 0 means UNASSESSED, not denied or proven invisible. */
    uint64_t architectural_channels;
} EPRCapPlan;
typedef struct {
    EPRCapRegion arguments;
    uint32_t entered, returned;
    int32_t status;
    uint32_t unmap_entered, unmap_returned;
    int32_t unmap_status;
} EPRCapMapCall;
typedef struct {
    EPRCapMapCall maps[cap_max_regions];
    uint64_t generation;
    uint32_t next, poisoned, run_entered, trap_checked, trap_matched;
    uint64_t reason, syndrome, pc, ipa, va, value;
} EPRCapTrace;

static inline EPRCapPlan cap_fixed_plan(uint64_t profile, uint64_t generation) {
    EPRCapPlan p = {0};
    p.version = 1; p.profile = profile; p.generation = generation;
    p.count = profile == 1 ? 3 : (profile == 2 ? 4 : 0);
    p.regions[0] = (EPRCapRegion){1, 0x10000000, cap_slot_bytes, 5};
    p.regions[1] = (EPRCapRegion){2, 0x10004000, cap_slot_bytes, 1};
    p.regions[2] = (EPRCapRegion){3, 0x10008000, cap_slot_bytes, 3};
    if (profile == 2) p.regions[3] = (EPRCapRegion){4, 0x10010000, cap_slot_bytes, 3};
    p.endpoint = 0x1000c000;
    p.pc = 0x10000000 + (profile == 2 ? 96 : 80);
    p.width = 4; p.value = 1;
    p.stack_top = profile == 2 ? 0x10014000 : 0x1000bff0;
    return p;
}

static inline bool cap_region_equal(EPRCapRegion a, EPRCapRegion b) {
    return a.object == b.object && a.ipa == b.ipa && a.length == b.length && a.rights == b.rights;
}

static inline bool cap_plan_valid(const EPRCapPlan *p, uint64_t generation) {
    if (!p || !generation || p->generation != generation ||
        (p->profile != 1 && p->profile != 2)) return false;
    const EPRCapPlan fixed = cap_fixed_plan(p->profile, generation);
    if (p->version != fixed.version || p->count != fixed.count ||
        p->endpoint != fixed.endpoint || p->pc != fixed.pc ||
        p->width != fixed.width || p->value != fixed.value ||
        p->stack_top != fixed.stack_top || p->architectural_channels != 0) return false;
    for (size_t i = 0; i < cap_max_regions; ++i) {
        if (!cap_region_equal(p->regions[i], fixed.regions[i])) return false;
        if (i >= p->count) continue;
        const EPRCapRegion r = p->regions[i];
        if (!r.length || r.ipa % cap_slot_bytes || r.length % cap_slot_bytes ||
            r.ipa > UINT64_MAX - r.length || (r.rights & 6) == 6 ||
            (p->endpoint >= r.ipa && p->endpoint < r.ipa + r.length)) return false;
        for (size_t j = 0; j < i; ++j) {
            const EPRCapRegion s = p->regions[j];
            if (r.object == s.object || (r.ipa < s.ipa + s.length && s.ipa < r.ipa + r.length)) return false;
        }
    }
    return true;
}

static inline EPRCapTrace cap_empty_trace(void) {
    EPRCapTrace t = {0};
    for (size_t i = 0; i < cap_max_regions; ++i)
        t.maps[i].status = t.maps[i].unmap_status = INT32_MIN;
    return t;
}

/* Entered is written immediately before the real call. Failure is sticky;
 * no caller-supplied operation table exists in the production executable. */
static inline bool cap_map_enter(const EPRCapPlan *p, EPRCapTrace *t,
                                 uint64_t generation, size_t index) {
    if (!cap_plan_valid(p, generation) || t->poisoned || t->run_entered ||
        index != t->next || index >= p->count || t->maps[index].entered ||
        (index == 0 ? t->generation != 0 : t->generation != generation)) {
        t->poisoned = 1; return false;
    }
    if (index && (!t->maps[index - 1].returned || t->maps[index - 1].status != 0)) {
        t->poisoned = 1; return false;
    }
    t->maps[index].arguments = p->regions[index];
    t->generation = generation;
    t->maps[index].entered = 1;
    ++t->next;
    return true;
}

static inline void cap_map_return(EPRCapTrace *t, size_t index, int32_t status) {
    if (index >= cap_max_regions || !t->maps[index].entered || t->maps[index].returned) {
        t->poisoned = 1; return;
    }
    t->maps[index].status = status;
    t->maps[index].returned = 1;
    if (status != 0) t->poisoned = 1;
}

static inline bool cap_maps_joined(const EPRCapPlan *p, const EPRCapTrace *t,
                                    uint64_t generation) {
    if (!cap_plan_valid(p, generation) || t->generation != generation ||
        t->poisoned || t->next != p->count) return false;
    for (size_t i = 0; i < cap_max_regions; ++i) {
        const EPRCapMapCall *m = &t->maps[i];
        if (i < p->count) {
            if (m->entered != 1 || m->returned != 1 || m->status != 0 ||
                !cap_region_equal(m->arguments, p->regions[i])) return false;
        } else if (m->entered || m->returned || m->status != INT32_MIN) return false;
    }
    return true;
}

static inline bool cap_run_enter(const EPRCapPlan *p, EPRCapTrace *t, uint64_t generation) {
    if (!cap_maps_joined(p, t, generation) || t->run_entered) { t->poisoned = 1; return false; }
    t->run_entered = 1;
    return true;
}

static inline bool cap_terminal(const EPRCapPlan *p, EPRCapTrace *t, uint64_t generation,
                                uint64_t reason, uint64_t syndrome, uint64_t pc,
                                uint64_t ipa, uint64_t va, uint64_t value) {
    if (!cap_maps_joined(p, t, generation) || t->run_entered != 1 || t->trap_checked) {
        t->poisoned = 1; return false;
    }
    t->trap_checked = 1;
    t->reason = reason; t->syndrome = syndrome; t->pc = pc;
    t->ipa = ipa; t->va = va; t->value = value;
    uint64_t dfsc = syndrome & 63;
    /* Apple HV_EXIT_REASON_EXCEPTION == 1 is checked at the native boundary.
     * EC/IL/ISV/SAS/SRT/sign/WnR are exact, except translation fault level. */
    t->trap_matched = reason == 1 && syndrome == (UINT64_C(0x93840040) | dfsc) &&
        dfsc >= 4 && dfsc <= 7 && pc == p->pc && ipa == p->endpoint &&
        va == p->endpoint && value == p->value && p->width == 4;
    if (!t->trap_matched) t->poisoned = 1;
    return t->trap_matched;
}

/* Legacy 128-byte layout frame, now reconstructed from joined call arguments.
 * This does not change its schema or pretend the old record included statuses. */
static inline bool cap_rust_memory_contract(const EPRCapPlan *p, const EPRCapTrace *t,
                                            uint64_t generation, unsigned char out[128]) {
    if (p->profile != 2 || !cap_maps_joined(p, t, generation)) return false;
    uint64_t words[16] = {0};
    for (size_t i = 0; i < 4; ++i) {
        words[3*i] = t->maps[i].arguments.ipa;
        words[3*i+1] = t->maps[i].arguments.length;
        words[3*i+2] = t->maps[i].arguments.rights;
    }
    words[12] = p->endpoint; words[13] = p->pc - p->regions[0].ipa;
    words[14] = p->stack_top; words[15] = 16;
    for (size_t i = 0; i < 16; ++i)
        for (size_t b = 0; b < 8; ++b) out[8*i+b] = (unsigned char)(words[i] >> (8*b));
    return true;
}

/* Versioned canonical big-endian observation: fixed 680 bytes. No padding,
 * host pointer, FD, environment value, or path enters this frame. */
enum { cap_witness_bytes = 680 };
static inline void cap_witness_word(unsigned char *out, size_t *offset, uint64_t value) {
    for (size_t i = 0; i < 8; ++i) out[(*offset)++] = (unsigned char)(value >> (8*(7-i)));
}
static inline void cap_encode_witness(const EPRCapPlan *p, const EPRCapTrace *t,
                                      const unsigned char image_digest[32],
                                      uint64_t image_size, bool admitted, bool conserved,
                                      unsigned char out[cap_witness_bytes]) {
    memset(out, 0, cap_witness_bytes);
    memcpy(out, "EPRCAP01", 8); size_t n = 8;
#define CW(v) cap_witness_word(out, &n, (uint64_t)(v))
    CW(p->version); CW(p->profile); CW(p->generation); CW(p->count);
    CW(image_size); memcpy(out+n, image_digest, 32); n += 32;
    CW(p->architectural_channels); CW(admitted); CW(t->poisoned);
    for (size_t i = 0; i < 4; ++i) {
        const EPRCapRegion r = p->regions[i], a = t->maps[i].arguments;
        const EPRCapMapCall m = t->maps[i];
        CW(r.object); CW(r.ipa); CW(r.length); CW(r.rights);
        CW(a.object); CW(a.ipa); CW(a.length); CW(a.rights);
        CW(m.entered); CW(m.returned); CW((int64_t)m.status);
        CW(m.unmap_entered); CW(m.unmap_returned); CW((int64_t)m.unmap_status);
    }
    CW(p->endpoint); CW(p->pc); CW(p->width); CW(p->value); CW(p->stack_top);
    CW(t->next); CW(t->run_entered); CW(t->trap_checked); CW(t->trap_matched);
    CW(t->reason); CW(t->syndrome); CW(t->pc); CW(t->ipa); CW(t->va); CW(t->value);
    CW(conserved);
#undef CW
    /* All680 bytes are explicit fields; no native struct representation. */
}
#endif
