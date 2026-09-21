/* Standalone host-only test of the SAME production body. All HV calls are
 * compile-time substitutes; link WITHOUT Hypervisor or Security frameworks.
 * No app/guest/process/signal/network action. Private mmap/pthreads are host
 * test mechanics. Production contains neither this fake state nor dispatch. */
#include <Hypervisor/Hypervisor.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

static hv_return_t fake_vm_create(hv_vm_config_t c);
static hv_return_t fake_vm_destroy(void);
static hv_return_t fake_vm_map(void *a, hv_ipa_t i, size_t s, hv_memory_flags_t f);
static hv_return_t fake_vm_unmap(hv_ipa_t i, size_t s);
static hv_return_t fake_vcpu_create(hv_vcpu_t *v, hv_vcpu_exit_t **e, hv_vcpu_config_t c);
static hv_return_t fake_vcpu_destroy(hv_vcpu_t v);
static hv_return_t fake_get_reg(hv_vcpu_t v, hv_reg_t r, uint64_t *o);
static hv_return_t fake_set_reg(hv_vcpu_t v, hv_reg_t r, uint64_t x);
static hv_return_t fake_get_sys(hv_vcpu_t v, hv_sys_reg_t r, uint64_t *o);
static hv_return_t fake_set_sys(hv_vcpu_t v, hv_sys_reg_t r, uint64_t x);
static hv_return_t fake_run(hv_vcpu_t v);
static hv_return_t fake_exit(const hv_vcpu_t *v, uint32_t c);
#define hv_vm_create fake_vm_create
#define hv_vm_destroy fake_vm_destroy
#define hv_vm_map fake_vm_map
#define hv_vm_unmap fake_vm_unmap
#define hv_vcpu_create fake_vcpu_create
#define hv_vcpu_destroy fake_vcpu_destroy
#define hv_vcpu_get_reg fake_get_reg
#define hv_vcpu_set_reg fake_set_reg
#define hv_vcpu_get_sys_reg fake_get_sys
#define hv_vcpu_set_sys_reg fake_set_sys
#define hv_vcpu_run fake_run
#define hv_vcpus_exit fake_exit
#include "../Sources/HypervisorGuest.c"

static struct {
    unsigned creates, maps, unmaps, runs, destroys;
    int failed_map, wrong_trap;
    void *pages[4]; EPRCapRegion actual[4];
    uint64_t cpsr, sctlr, sp, pc;
    hv_vcpu_exit_t exit;
} fake;

int epr_admit_signing(const char *team, int *error) {
    assert(!strcmp(team, "ZCQ435U8JP")); *error = 0; return 1;
}
static hv_return_t fake_vm_create(hv_vm_config_t c) { assert(!c); ++fake.creates; return 0; }
static hv_return_t fake_vm_destroy(void) { ++fake.destroys; return 0; }
static hv_return_t fake_vm_map(void *a, hv_ipa_t i, size_t s, hv_memory_flags_t f) {
    assert(fake.maps < 4 && a && (uintptr_t)a % 16384 == 0);
    unsigned n = fake.maps++;
    fake.pages[n] = a; fake.actual[n] = (EPRCapRegion){n+1, i, s, f};
    return fake.failed_map == (int)n ? HV_ERROR : HV_SUCCESS;
}
static hv_return_t fake_vm_unmap(hv_ipa_t i, size_t s) {
    assert(fake.unmaps < fake.maps);
    EPRCapRegion a = fake.actual[fake.unmaps++];
    assert(a.ipa == i && a.length == s); return 0;
}
static hv_return_t fake_vcpu_create(hv_vcpu_t *v, hv_vcpu_exit_t **e, hv_vcpu_config_t c) {
    assert(!c); *v = 73; *e = &fake.exit; return 0;
}
static hv_return_t fake_vcpu_destroy(hv_vcpu_t v) { assert(v == 73); return 0; }
static hv_return_t fake_set_reg(hv_vcpu_t v, hv_reg_t r, uint64_t x) {
    assert(v == 73);
    if (r == HV_REG_PC) fake.pc = x;
    if (r == HV_REG_CPSR) fake.cpsr = x;
    return 0;
}
static hv_return_t fake_get_reg(hv_vcpu_t v, hv_reg_t r, uint64_t *o) {
    assert(v == 73);
    if (r == HV_REG_PC) *o = fake.pc;
    else if (r == HV_REG_X4) *o = 1;
    else if (r == HV_REG_CPSR) *o = fake.cpsr;
    else abort();
    return 0;
}
static hv_return_t fake_set_sys(hv_vcpu_t v, hv_sys_reg_t r, uint64_t x) {
    assert(v == 73);
    if (r == HV_SYS_REG_SCTLR_EL1) fake.sctlr = x;
    else if (r == HV_SYS_REG_SP_EL1) fake.sp = x;
    else assert(r == HV_SYS_REG_VBAR_EL1 && x == 0);
    return 0;
}
static hv_return_t fake_get_sys(hv_vcpu_t v, hv_sys_reg_t r, uint64_t *o) {
    assert(v == 73);
    if (r == HV_SYS_REG_SCTLR_EL1) *o = fake.sctlr;
    else if (r == HV_SYS_REG_SP_EL1) *o = fake.sp;
    else abort();
    return 0;
}
static hv_return_t fake_run(hv_vcpu_t v) {
    assert(v == 73 && fake.runs++ == 0 && fake.maps >= 3);
    memcpy(fake.pages[2], expected_reply, sizeof(expected_reply));
    if (fake.maps == 4) memcpy((char *)fake.pages[3]+16384-16, rust_expected_stack_frame, 16);
    fake.pc += fake.maps == 4 ? 96 : 80;
    fake.exit.reason = HV_EXIT_REASON_EXCEPTION;
    fake.exit.exception.syndrome = 0x93840044;
    fake.exit.exception.physical_address = 0x1000c000 + (fake.wrong_trap ? 4 : 0);
    fake.exit.exception.virtual_address = 0x1000c000;
    return 0;
}
static hv_return_t fake_exit(const hv_vcpu_t *v, uint32_t c) {
    (void)v; (void)c; abort(); /* Tests must never reach watchdog cancellation. */
}

static unsigned checks;
#define CHECK(v) do { ++checks; if (!(v)) { fprintf(stderr,"FAIL %d: %s\n",__LINE__,#v); abort(); } } while(0)

static EPRCapTrace complete_maps(EPRCapPlan p) {
    EPRCapTrace t = cap_empty_trace();
    for (size_t i = 0; i < p.count; ++i) {
        CHECK(cap_map_enter(&p,&t,p.generation,i)); cap_map_return(&t,i,0);
    }
    return t;
}
static void pure_negatives(void) {
    for (uint64_t profile = 1; profile <= 2; ++profile) {
        EPRCapPlan p = cap_fixed_plan(profile,7), q = p;
        CHECK(cap_plan_valid(&p,7)); CHECK(!cap_plan_valid(&p,8));
        q.generation=0; CHECK(!cap_plan_valid(&q,0)); q=p;
        q.profile=3; CHECK(!cap_plan_valid(&q,7)); q=p;
        q.count=5; CHECK(!cap_plan_valid(&q,7)); q=p;
        q.version=2; CHECK(!cap_plan_valid(&q,7)); q=p;
        q.architectural_channels=1; CHECK(!cap_plan_valid(&q,7)); q=p;
        for (size_t i=0;i<p.count;++i) {
            q=p; q.regions[i].object=99; CHECK(!cap_plan_valid(&q,7));
            q=p; q.regions[i].ipa++; CHECK(!cap_plan_valid(&q,7));
            q=p; q.regions[i].ipa=UINT64_MAX-100; CHECK(!cap_plan_valid(&q,7));
            q=p; q.regions[i].length=UINT64_MAX; CHECK(!cap_plan_valid(&q,7));
            q=p; q.regions[i].rights=7; CHECK(!cap_plan_valid(&q,7));
            q=p; q.regions[i].ipa=p.endpoint; CHECK(!cap_plan_valid(&q,7));
        }
        q=p; q.regions[1]=q.regions[0]; CHECK(!cap_plan_valid(&q,7));
        q=p; q.endpoint++; CHECK(!cap_plan_valid(&q,7));
        q=p; q.width=8; CHECK(!cap_plan_valid(&q,7));
        EPRCapTrace t=cap_empty_trace();
        CHECK(!cap_map_enter(&p,&t,7,1)); CHECK(!cap_map_enter(&p,&t,7,0));
        t=cap_empty_trace(); CHECK(cap_map_enter(&p,&t,7,0));
        CHECK(!cap_map_enter(&p,&t,7,1)); /* Return missing. */
        t=cap_empty_trace(); CHECK(cap_map_enter(&p,&t,7,0)); cap_map_return(&t,0,-3);
        CHECK(!cap_map_enter(&p,&t,7,1)); CHECK(!cap_run_enter(&p,&t,7));
        t=complete_maps(p); CHECK(cap_maps_joined(&p,&t,7));
        q=cap_fixed_plan(profile,8); CHECK(!cap_maps_joined(&q,&t,8));
        t.maps[0].arguments.rights=7; CHECK(!cap_maps_joined(&p,&t,7));
        t=complete_maps(p); CHECK(cap_run_enter(&p,&t,7)); CHECK(!cap_run_enter(&p,&t,7));
        for (unsigned field=0;field<7;++field) {
            t=complete_maps(p); CHECK(cap_run_enter(&p,&t,7));
            CHECK(!cap_terminal(&p,&t,7,field==0?0:1,field==1?0x93840048:0x93840044,
                p.pc+(field==2?4:0),p.endpoint+(field==3?4:0),p.endpoint+(field==4?4:0),field==5?2:1) || field==6);
            if(field==6) CHECK(!cap_terminal(&p,&t,7,1,0x93840044,p.pc,p.endpoint,p.endpoint,1));
        }
        for (uint64_t dfsc=4;dfsc<=7;++dfsc) {
            t=complete_maps(p); CHECK(cap_run_enter(&p,&t,7));
            CHECK(cap_terminal(&p,&t,7,1,0x93840040|dfsc,p.pc,p.endpoint,p.endpoint,1));
        }
        if(profile==2) {
            unsigned char b[128]; t=complete_maps(p);
            CHECK(cap_rust_memory_contract(&p,&t,7,b)); CHECK(!memcmp(b,rust_memory_contract,128));
        }
    }
}

typedef struct { bool rust; EPRGuestReservation *token; EPRGuestResult result; } Work;
static void *run_worker(void *v) {
    Work *w=v;
    w->result=w->rust ? epr_rust_guest_run_reserved(w->token).base : epr_guest_run_reserved(w->token);
    return NULL;
}
static uint64_t word(const unsigned char *b, size_t n) {
    uint64_t v=0; for(size_t i=0;i<8;++i) v=(v<<8)|b[n+i]; return v;
}
static void production_path(bool rust, int failed_map, bool wrong_trap) {
    memset(&fake,0,sizeof(fake)); fake.failed_map=failed_map; fake.wrong_trap=wrong_trap;
    int error=0; EPRGuestReservation *token=epr_guest_reserve(&error);
    CHECK(token && !error);
    EPRGuestCapabilityWitness observation={0};
    CHECK(epr_guest_reservation_copy_capability_witness(token,&observation)==ENODATA);
    Work work={.rust=rust,.token=token}; pthread_t thread;
    CHECK(!pthread_create(&thread,NULL,run_worker,&work)); CHECK(!pthread_join(thread,NULL));
    CHECK(!epr_guest_reservation_copy_capability_witness(token,&observation));
    CHECK(observation.byte_count==680 && !memcmp(observation.bytes,"EPRCAP01",8));
    CHECK(word(observation.bytes,24)==token->generation);
    CHECK(work.result.teardown_pass==1 && !work.result.resources_quarantined);
    CHECK(fake.creates==1 && fake.destroys==1);
    CHECK(fake.maps==(failed_map>=0 ? (unsigned)failed_map+1 : (rust?4:3)));
    CHECK(fake.runs==(failed_map>=0 ? 0u:1u));
    CHECK(fake.unmaps==(failed_map>=0 ? (unsigned)failed_map:(rust?4:3)));
    for(size_t i=0;i<fake.maps;++i) {
        const EPRCapPlan p=cap_fixed_plan(rust?2:1,token->generation);
        CHECK(cap_region_equal(fake.actual[i],p.regions[i]));
        size_t offset=104+i*112;
        CHECK(word(observation.bytes,offset+32)==fake.actual[i].object);
        CHECK(word(observation.bytes,offset+40)==fake.actual[i].ipa);
        CHECK(word(observation.bytes,offset+48)==fake.actual[i].length);
        CHECK(word(observation.bytes,offset+56)==fake.actual[i].rights);
        CHECK(word(observation.bytes,offset+64)==1 && word(observation.bytes,offset+72)==1);
    }
    CHECK(work.result.outcome==((failed_map<0 && !wrong_trap)?EPR_GUEST_PASS:EPR_GUEST_FAILED));
    EPRGuestResult replay=epr_guest_run_reserved(token); CHECK(replay.outcome==EPR_GUEST_FAILED);
    EPRGuestCapabilityWitness again={0}; CHECK(!epr_guest_reservation_copy_capability_witness(token,&again));
    CHECK(!memcmp(again.bytes,observation.bytes,680));
    printf("{\"schema\":\"ergentics.capability.fake-native.v1\",\"profile\":%d,\"failed_map\":%d,\"wrong_trap\":%d,\"actual_hv_calls\":0,\"frame_hex\":\"",rust?2:1,failed_map,wrong_trap);
    for(size_t i=0;i<680;++i) printf("%02x",observation.bytes[i]);
    puts("\"}");
    CHECK(!epr_guest_reservation_release(token));
}
int main(void) {
    pure_negatives();
    production_path(false,-1,false); production_path(true,-1,false);
    production_path(true,-1,true);
    for(int i=0;i<4;++i) production_path(true,i,false);
    printf("{\"status\":\"PASS\",\"checks\":%u,\"production_body_fake_runs\":7,\"guest_entries\":0}\n",checks);
    return 0;
}
