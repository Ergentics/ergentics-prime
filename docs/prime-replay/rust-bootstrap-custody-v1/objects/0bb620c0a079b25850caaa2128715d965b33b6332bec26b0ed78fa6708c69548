#!/usr/bin/ruby
# frozen_string_literal: true

# Offline build-artifact validation only. This is not a guest image loader and
# never starts another program, maps guest memory, or changes an app contract.
require 'digest'
require 'json'

module ErgenticsRustBootstrap
  class ValidationError < StandardError; end

  Analysis = Struct.new(:image, :record, keyword_init: true)

  class Inspector
    MAX_ELF_BYTES = 16 * 1024 * 1024
    MAX_IMAGE_BYTES = 16_384
    MAX_SECTIONS = 128
    MAX_PROGRAM_HEADERS = 16
    MAX_SYMBOLS = 4096
    MAX_NAME_BYTES = 4096
    BASE = 0x10000000
    STACK_BOTTOM = 0x10010000
    STACK_TOP = 0x10014000
    REQUIRED_TEXT_SYMBOLS = %w[
      _start epr_guest_evaluate epr_guest_doorbell epr_guest_reject
      epr_guest_returned_doorbell epr_guest_panic
    ].freeze
    REQUIRED_ABSOLUTES = {
      '__stack_bottom' => STACK_BOTTOM,
      '__stack_top' => STACK_TOP
    }.freeze

    def self.inspect_bytes(bytes)
      new(bytes).inspect
    end

    def initialize(bytes)
      check(bytes.is_a?(String), 'ELF input must be bytes')
      check(bytes.bytesize.between?(64, MAX_ELF_BYTES), 'ELF byte bound')
      @bytes = bytes.dup.force_encoding(Encoding::BINARY).freeze
    end

    def inspect
      check(@bytes.byteslice(0, 4) == "\x7fELF".b, 'ELF magic')
      check(u8(4) == 2 && u8(5) == 1 && u8(6) == 1, 'Require ELF64 little endian version 1')
      check(u8(7).zero? && u8(8).zero? && @bytes.byteslice(9, 7) == "\0" * 7,
            'Require System V ELF ABI version 0 and zero identification padding')
      check(u16(16) == 2 && u16(18) == 183 && u32(20) == 1,
            'Require AArch64 ET_EXEC, not an object, shared library or Darwin image')
      check(u64(24) == BASE && u32(48).zero? && u16(52) == 64, 'ELF entry, flags or header size')

      phoff = u64(32)
      shoff = u64(40)
      phnum = u16(56)
      shnum = u16(60)
      shstrndx = u16(62)
      check(u16(54) == 56 && phnum.between?(1, MAX_PROGRAM_HEADERS), 'Program header bounds')
      check(u16(58) == 64 && shnum.between?(2, MAX_SECTIONS), 'Section header bounds; extended numbering unsupported')
      check(shstrndx.positive? && shstrndx < shnum, 'Section-name table index')
      range(phoff, phnum * 56, 'Program header table')
      range(shoff, shnum * 64, 'Section header table')
      regions = [[0, 64, 'ELF header'], [phoff, phnum * 56, 'program headers'],
                 [shoff, shnum * 64, 'section headers']]

      sections = Array.new(shnum) do |index|
        at = shoff + index * 64
        { index: index, name_index: u32(at), type: u32(at + 4), flags: u64(at + 8),
          address: u64(at + 16), offset: u64(at + 24), size: u64(at + 32),
          link: u32(at + 40), info: u32(at + 44), alignment: u64(at + 48),
          entry_size: u64(at + 56) }
      end
      check(@bytes.byteslice(shoff, 64) == "\0" * 64, 'Null section must be empty')
      sections.drop(1).each do |section|
        check([1, 2, 3, 7].include?(section[:type]),
              'Unsupported section type (including relocation, dynamic, TLS or NOBITS)')
        check((section[:flags] & 0x400).zero?, 'TLS section forbidden')
        check((section[:flags] & 0x80000800).zero?, 'Compressed or excluded sections unsupported')
        check(section[:alignment].zero? || power_of_two?(section[:alignment]), 'Section alignment')
        range(section[:offset], section[:size], 'Section contents')
        if section[:type] == 3
          check(section[:size].positive? && u8(section[:offset]).zero? &&
                u8(section[:offset] + section[:size] - 1).zero?, 'String table requires boundary null bytes')
        end
        regions << [section[:offset], section[:size], "section #{section[:index]}"] if section[:size].positive?
      end
      no_overlaps(regions)

      names = sections[shstrndx]
      check(names[:type] == 3 && names[:size].positive?, 'Section names must be a string table')
      sections.each { |section| section[:name] = string_at(names, section[:name_index]) }
      named = sections.drop(1).map { |section| section[:name] }
      check(named.all? { |name| !name.empty? } && named.uniq.size == named.size, 'Empty or duplicate section name')
      text_sections = sections.select { |section| section[:name] == '.text' }
      check(text_sections.length == 1, 'Exactly one .text section required')
      text = text_sections.first
      check(text[:type] == 1 && text[:flags] == 6 && text[:address] == BASE,
            '.text must be non-writable allocated executable PROGBITS at the fixed base')
      check(text[:size].between?(4, MAX_IMAGE_BYTES) && (text[:size] % 4).zero?, '.text size/instruction alignment')
      check(text[:alignment].between?(4, MAX_IMAGE_BYTES) && (BASE % text[:alignment]).zero?, '.text alignment')
      sections.drop(1).each do |section|
        next if section.equal?(text)
        check((section[:flags] & 2).zero? || section[:size].zero?, 'Additional allocated section forbidden')
        check((section[:flags] & 5).zero?, 'Writable/executable section outside .text forbidden')
        check(section[:address].zero?, 'Non-text section must not designate a guest address')
      end

      headers = Array.new(phnum) do |index|
        at = phoff + index * 56
        { type: u32(at), flags: u32(at + 4), offset: u64(at + 8),
          virtual_address: u64(at + 16), physical_address: u64(at + 24),
          file_size: u64(at + 32), memory_size: u64(at + 40), alignment: u64(at + 48) }
      end
      loads = headers.select { |header| header[:type] == 1 }
      check(loads.length == 1, 'Exactly one PT_LOAD required')
      load = loads.first
      check(load[:flags] == 5 && load[:virtual_address] == BASE && load[:physical_address] == BASE,
            'PT_LOAD must be fixed-address read/execute only')
      check(load[:offset] == text[:offset] && load[:file_size] == text[:size] &&
            load[:memory_size] == text[:size], 'PT_LOAD must contain exactly .text, with no header, BSS or extra bytes')
      check(power_of_two?(load[:alignment]) && load[:alignment] <= 65_536 &&
            load[:virtual_address] % load[:alignment] == load[:offset] % load[:alignment], 'PT_LOAD alignment')
      headers.each do |header|
        next if header.equal?(load)
        # GNU_STACK is link metadata, not a mapped guest stack. An explicit
        # separate stack mapping remains the host's future responsibility.
        check(header[:type] == 0x6474e551 && [4, 6].include?(header[:flags]) &&
              header[:file_size].zero? && header[:memory_size].zero? &&
              header[:virtual_address].zero? && header[:physical_address].zero?,
              'Non-load program header forbidden except empty non-executable GNU_STACK')
      end
      check(headers.count { |header| header[:type] == 0x6474e551 } <= 1, 'Duplicate GNU_STACK header')

      symbol_tables = sections.select { |section| section[:type] == 2 }
      check(symbol_tables.length == 1, 'One full static symbol table required')
      table = symbol_tables.first
      check(table[:entry_size] == 24 && (table[:size] % 24).zero? &&
            (table[:size] / 24).between?(1, MAX_SYMBOLS), 'Symbol table bound/entry size')
      check(table[:link].positive? && table[:link] < sections.length, 'Symbol string-table index')
      strings = sections[table[:link]]
      check(strings[:type] == 3 && strings[:size].positive?, 'Symbol names must use a string table')
      count = table[:size] / 24
      check(table[:info].between?(1, count), 'Symbol local/global boundary')
      symbols = Array.new(count) do |index|
        at = table[:offset] + index * 24
        raw = @bytes.byteslice(at, 24)
        if index.zero?
          check(raw == "\0" * 24, 'First symbol must be the null symbol')
          next nil
        end
        info = u8(at + 4)
        symbol = { name: string_at(strings, u32(at)), binding: info >> 4, type: info & 15,
                   visibility: u8(at + 5), section_index: u16(at + 6),
                   address: u64(at + 8), size: u64(at + 16) }
        check([0, 1, 2].include?(symbol[:binding]) && [0, 1, 2, 3, 4].include?(symbol[:type]) &&
              symbol[:visibility] <= 3, 'Unsupported symbol binding/type/visibility (TLS/IFUNC forbidden)')
        check((index < table[:info]) == symbol[:binding].zero?, 'Symbol local/global ordering')
        check(symbol[:section_index] != 0, 'Undefined/imported symbol forbidden')
        check(symbol[:section_index] == 0xfff1 || symbol[:section_index] < sections.length,
              'Common, extended or reserved symbol section index forbidden')
        if symbol[:section_index] != 0xfff1
          owner = sections[symbol[:section_index]]
          check(symbol[:address] >= owner[:address] && symbol[:address] <= owner[:address] + owner[:size] &&
                symbol[:size] <= owner[:address] + owner[:size] - symbol[:address], 'Symbol leaves its section')
          if symbol[:type] == 2
            check(owner.equal?(text) && symbol[:address] < BASE + text[:size] && (symbol[:address] % 4).zero?,
                  'Function must be instruction-aligned inside .text')
          end
        else
          check(symbol[:type] != 2, 'Absolute function symbol forbidden')
        end
        symbol
      end.compact

      required = {}
      REQUIRED_TEXT_SYMBOLS.each do |name|
        matches = symbols.select { |symbol| symbol[:name] == name }
        check(matches.length == 1, "Missing or duplicate required symbol #{name}")
        symbol = matches.first
        check(symbol[:binding] == 1 && [0, 2].include?(symbol[:type]) &&
              symbol[:section_index] == text[:index] && symbol[:address] >= BASE &&
              symbol[:address] + 4 <= BASE + text[:size] && (symbol[:address] % 4).zero?,
              "Required symbol must be global and inside .text: #{name}")
        required[name] = symbol
      end
      check(required['_start'][:address] == BASE, '_start must match ELF entry')
      check(required['epr_guest_evaluate'][:type] == 2, 'Rust evaluator must be a function symbol')
      REQUIRED_ABSOLUTES.each do |name, address|
        matches = symbols.select { |symbol| symbol[:name] == name }
        check(matches.length == 1 && matches.first[:binding] == 1 &&
              matches.first[:type] == 0 && matches.first[:section_index] == 0xfff1 &&
              matches.first[:address] == address && matches.first[:size].zero?,
              "Required absolute stack symbol #{name}")
        required[name] = matches.first
      end

      image = @bytes.byteslice(text[:offset], text[:size]).freeze
      bell_offset = required['epr_guest_doorbell'][:address] - BASE
      check(bell_offset >= 8, 'Doorbell needs its release/barrier prefix')
      check(image.byteslice(bell_offset - 8, 12).unpack('L<3') == [0xc89ffc24, 0xd5033f9f, 0xb9000064],
            'Doorbell must be exactly STLR X4,[X1]; DSB SY; STR W4,[X3]')
      record = {
        'schema' => 'ergentics.rust-bootstrap.elf-inspection.v1',
        'status' => 'STATIC_BUILD_ONLY',
        'elf' => { 'sha256' => Digest::SHA256.hexdigest(@bytes), 'bytes' => @bytes.bytesize,
                   'class' => 'ELF64', 'endianness' => 'little', 'machine' => 'AArch64',
                   'type' => 'ET_EXEC', 'entry' => BASE, 'program_headers' => phnum,
                   'sections' => shnum, 'symbols_including_null' => count },
        'image' => { 'file' => 'image.bin', 'sha256' => Digest::SHA256.hexdigest(image),
                     'bytes' => image.bytesize, 'load_address' => BASE, 'section' => '.text' },
        'load_segment' => load.transform_keys(&:to_s),
        'required_symbols' => required.transform_values { |value| value.transform_keys(&:to_s) },
        'doorbell' => { 'offset' => bell_offset, 'word' => 'b9000064',
                        'preceding_words' => %w[c89ffc24 d5033f9f] },
        'stack' => { 'bottom' => STACK_BOTTOM, 'top' => STACK_TOP, 'bytes' => STACK_TOP - STACK_BOTTOM,
                     'allocated_in_elf' => false, 'host_mapping_performed' => false },
        'limits' => { 'elf_bytes' => MAX_ELF_BYTES, 'image_bytes' => MAX_IMAGE_BYTES,
                      'sections' => MAX_SECTIONS, 'program_headers' => MAX_PROGRAM_HEADERS, 'symbols' => MAX_SYMBOLS },
        'not_proven' => ['Instruction-set/FP/SIMD compatibility', 'Stack usage or bounds',
                         'Control-flow or panic-path correctness', 'Runtime imports hidden in machine instructions',
                         'Guest execution, host integrity, isolation, result correctness or scientific authority'],
        'manual_review_required' => 'Review separately retained disassembly and linker/source contracts before any new guest admission.',
        'publication' => 'Exclusive image.bin then inspection.json; a failed prefix remains retained. The record does not contain its own digest.'
      }
      Analysis.new(image: image, record: record)
    end

    private

    def check(condition, message)
      raise ValidationError, message unless condition
    end

    def range(offset, length, label)
      check(offset >= 0 && length >= 0 && offset <= @bytes.bytesize && length <= @bytes.bytesize - offset,
            "#{label} exceeds the ELF byte range")
    end

    def no_overlaps(regions)
      regions.sort_by(&:first).each_cons(2) do |left, right|
        check(left[0] + left[1] <= right[0], "Overlapping #{left[2]} and #{right[2]}")
      end
    end

    def string_at(table, offset)
      check(offset < table[:size], 'String-table offset')
      start = table[:offset] + offset
      finish = @bytes.index("\0", start)
      check(finish && finish < table[:offset] + table[:size] && finish - start <= MAX_NAME_BYTES,
            'Unterminated or oversized ELF name')
      value = @bytes.byteslice(start, finish - start).dup.force_encoding(Encoding::UTF_8)
      check(value.valid_encoding? && !value.match?(/[\x00-\x1f\x7f]/), 'Invalid ELF name text')
      value
    end

    def power_of_two?(value)
      value.positive? && (value & (value - 1)).zero?
    end

    def u8(at); @bytes.getbyte(at); end
    def u16(at); @bytes.byteslice(at, 2).unpack1('S<'); end
    def u32(at); @bytes.byteslice(at, 4).unpack1('L<'); end
    def u64(at); @bytes.byteslice(at, 8).unpack1('Q<'); end
  end

  module CLI
    module_function

    def metadata(stat)
      [stat.dev, stat.ino, stat.mode, stat.uid, stat.gid, stat.nlink, stat.size,
       stat.mtime.to_i, stat.mtime.nsec, stat.ctime.to_i, stat.ctime.nsec]
    end

    def directory_identity(stat)
      [stat.dev, stat.ino, stat.mode, stat.uid, stat.gid]
    end

    def fail_unless(condition, message)
      raise ValidationError, message unless condition
    end

    def read_elf(path)
      File.open(path, File::RDONLY | File::NOFOLLOW | File::NONBLOCK) do |file|
        file.binmode
        before = file.stat
        fail_unless(before.file? && before.size.between?(64, Inspector::MAX_ELF_BYTES), 'Input is not a bounded regular ELF file')
        bytes = file.read(Inspector::MAX_ELF_BYTES + 1)
        after = file.stat
        fail_unless(bytes && bytes.bytesize == before.size && metadata(before) == metadata(after) &&
                    metadata(after) == metadata(File.lstat(path)), 'ELF input changed during capture')
        [bytes, after]
      end
    end

    def write_exclusive(name, bytes)
      File.open(name, File::WRONLY | File::CREAT | File::EXCL | File::NOFOLLOW, 0600) do |file|
        file.binmode
        stat = file.stat
        fail_unless(stat.file? && (stat.mode & 07777) == 0600 && stat.uid == Process.euid && stat.nlink == 1,
                    'New output leaf metadata rejected; retained without repair')
        offset = 0
        while offset < bytes.bytesize
          written = file.write(bytes.byteslice(offset, bytes.bytesize - offset))
          fail_unless(written && written.positive?, 'Incomplete output write; prefix retained')
          offset += written
        end
        file.flush
        file.fsync
        fail_unless(file.stat.size == bytes.bytesize && file.stat.ino == File.lstat(name).ino &&
                    file.stat.dev == File.lstat(name).dev, 'Output leaf changed; retained without repair')
      end
    end

    def run(arguments)
      fail_unless(arguments.length == 2, 'Usage: inspect.rb ELF_PATH EXISTING_PRIVATE_OUTPUT_DIRECTORY')
      input = File.expand_path(arguments[0])
      destination = File.expand_path(arguments[1])
      bytes, input_stat = read_elf(input)
      analysis = Inspector.inspect_bytes(bytes)
      json = JSON.pretty_generate(analysis.record) + "\n"
      File.open(destination, File::RDONLY | File::NOFOLLOW | File::NONBLOCK) do |directory|
        original = directory.stat
        fail_unless(original.directory? && (original.mode & 07777) == 0700 && original.uid == Process.euid &&
                    directory_identity(original) == directory_identity(File.lstat(destination)),
                    'Output directory must already exist, be self-owned 0700 and not a symlink')
        # chdir affects only this single-threaded inspector process. A joined
        # current directory anchors relative output names; no Ruby FFI/openat.
        Dir.chdir(destination) do
          fail_unless(directory_identity(original) == directory_identity(File.stat('.')),
                      'Output directory changed before publication')
          %w[image.bin inspection.json].each do |name|
            begin
              File.lstat(name)
              raise ValidationError, "Output already exists: #{name}; no overwrite or cleanup"
            rescue Errno::ENOENT
              # Exclusive creation below also handles a later collision.
            end
          end
          prior_umask = File.umask(0077)
          begin
            write_exclusive('image.bin', analysis.image)
            write_exclusive('inspection.json', json)
            directory.fsync
            fail_unless(directory_identity(original) == directory_identity(File.lstat(destination)),
                        'Output directory name changed; created outcomes retained')
          ensure
            File.umask(prior_umask)
          end
        end
      end
      STDOUT.write("STATIC_BUILD_ONLY image_bytes=#{analysis.image.bytesize} image_sha256=#{analysis.record['image']['sha256']} doorbell_offset=#{analysis.record['doorbell']['offset']} input_device=#{input_stat.dev} input_inode=#{input_stat.ino}\n")
      0
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    exit ErgenticsRustBootstrap::CLI.run(ARGV)
  rescue StandardError => error
    STDERR.write("ELF_INSPECTION_FAILED #{error.class}: #{error.message}; any created output prefix is retained\n")
    exit 1
  end
end
