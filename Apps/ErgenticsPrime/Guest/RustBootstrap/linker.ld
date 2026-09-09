OUTPUT_FORMAT(elf64-littleaarch64)
OUTPUT_ARCH(aarch64)
ENTRY(_start)

PHDRS { code PT_LOAD FLAGS(5); }

__stack_bottom = 0x10010000;
__stack_top = 0x10014000;

SECTIONS {
    . = 0x10000000;
    .text : ALIGN(4) {
        KEEP(*(.text.boot))
        *(.text .text.*)
        *(.rodata .rodata.*)
    } :code
    __image_end = .;

    .data : { *(.data .data.* .sdata .sdata.*) } :code
    .bss : { *(.bss .bss.* .sbss .sbss.*) *(COMMON) } :code
    .tdata : { *(.tdata .tdata.*) } :code
    .tbss : { *(.tbss .tbss.*) } :code
    .init_array : { KEEP(*(.init_array .init_array.* .ctors .ctors.* .preinit_array .preinit_array.*)) } :code
    .fini_array : { KEEP(*(.fini_array .fini_array.* .dtors .dtors.*)) } :code
    .got : { *(.got .got.* .igot .igot.*) } :code
    .plt : { *(.plt .plt.* .iplt .iplt.*) } :code

    /DISCARD/ : { *(.comment .note.GNU-stack) }
}

ASSERT(_start == 0x10000000, "entry must equal fixed code base")
ASSERT(SIZEOF(.text) > 0 && SIZEOF(.text) <= 0x4000, "image must fit code slot")
ASSERT(SIZEOF(.data) == 0 && SIZEOF(.bss) == 0, "writable data forbidden")
ASSERT(SIZEOF(.tdata) == 0 && SIZEOF(.tbss) == 0, "TLS forbidden")
ASSERT(SIZEOF(.init_array) == 0 && SIZEOF(.fini_array) == 0, "constructors forbidden")
ASSERT(SIZEOF(.got) == 0 && SIZEOF(.plt) == 0, "dynamic indirection forbidden")
