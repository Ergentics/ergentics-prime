#!/usr/bin/ruby
# frozen_string_literal: true

# Pure synthetic-byte tests. Requiring inspect.rb performs no file admission,
# publication, compiler entry, process spawn or guest execution.
require_relative 'inspect'

class RustBootstrapInspectorTests
  # Deliberately stdlib-only: the frozen build uses Ruby --disable-gems.
  attr_reader :assertions

  def initialize
    @assertions = 0
  end

  def assert_equal(expected, actual)
    @assertions += 1
    raise "Expected #{expected.inspect}; received #{actual.inspect}" unless expected == actual
  end

  def refute_equal(expected, actual)
    @assertions += 1
    raise 'Unexpected equal values' if expected == actual
  end

  def assert_includes(values, expected)
    @assertions += 1
    raise "Missing expected value #{expected.inspect}" unless values.include?(expected)
  end

  def assert_raises(error_class)
    @assertions += 1
    begin
      yield
    rescue error_class
      return
    end
    raise "Expected #{error_class} rejection"
  end

  INSPECTOR = ErgenticsRustBootstrap::Inspector
  BASE = INSPECTOR::BASE
  TEXT_OFFSET = 0x1000
  TEXT_WORDS = [0xd503201f, 0xd65f03c0, 0xc89ffc24, 0xd5033f9f,
                0xb9000064, 0xd43bd5a0, 0xd42175a0, 0xd4200000].freeze

  def fixture
    text = TEXT_WORDS.pack('L<*')
    shnames = "\0.text\0.symtab\0.strtab\0.shstrtab\0".b
    names = %w[_start epr_guest_evaluate epr_guest_doorbell epr_guest_reject
               epr_guest_returned_doorbell epr_guest_panic __stack_bottom __stack_top]
    strings = "\0".b
    offsets = {}
    names.each { |name| offsets[name] = strings.bytesize; strings << name << "\0" }
    values = [BASE, BASE + 4, BASE + 16, BASE + 24, BASE + 20, BASE + 28,
              INSPECTOR::STACK_BOTTOM, INSPECTOR::STACK_TOP]
    symbols = "\0".b * 24
    names.each_with_index do |name, index|
      type = name == 'epr_guest_evaluate' ? 2 : 0
      symbols << [offsets[name], 0x10 | type, 0, index < 6 ? 1 : 0xfff1,
                  values[index], 0].pack('L<CCS<Q<Q<')
    end
    symoff = TEXT_OFFSET + text.bytesize
    stroff = symoff + symbols.bytesize
    shstroff = stroff + strings.bytesize
    shoff = (shstroff + shnames.bytesize + 7) & ~7
    bytes = "\0".b * (shoff + 5 * 64)
    bytes[0, 16] = "\x7fELF\x02\x01\x01".b + "\0" * 9
    bytes[16, 48] = [2, 183, 1, BASE, 64, shoff, 0, 64, 56, 1, 64, 5, 4].pack('S<S<L<Q<Q<Q<L<S<S<S<S<S<S<')
    bytes[64, 56] = [1, 5, TEXT_OFFSET, BASE, BASE, text.bytesize, text.bytesize, 0x1000].pack('L<L<Q<Q<Q<Q<Q<Q<')
    bytes[TEXT_OFFSET, text.bytesize] = text
    bytes[symoff, symbols.bytesize] = symbols
    bytes[stroff, strings.bytesize] = strings
    bytes[shstroff, shnames.bytesize] = shnames
    rows = [
      [shnames.index('.text'), 1, 6, BASE, TEXT_OFFSET, text.bytesize, 0, 0, 4, 0],
      [shnames.index('.symtab'), 2, 0, 0, symoff, symbols.bytesize, 3, 1, 8, 24],
      [shnames.index('.strtab'), 3, 0, 0, stroff, strings.bytesize, 0, 0, 1, 0],
      [shnames.index('.shstrtab'), 3, 0, 0, shstroff, shnames.bytesize, 0, 0, 1, 0]
    ]
    rows.each_with_index { |row, index| bytes[shoff + (index + 1) * 64, 64] = row.pack('L<L<Q<Q<Q<Q<L<L<Q<Q<') }
    { bytes: bytes, shoff: shoff, symoff: symoff, stroff: stroff, shstroff: shstroff }
  end

  def rejected(bytes)
    assert_raises(ErgenticsRustBootstrap::ValidationError) { INSPECTOR.inspect_bytes(bytes) }
  end

  def test_minimal_static_image_and_derived_doorbell
    result = INSPECTOR.inspect_bytes(fixture[:bytes])
    assert_equal TEXT_WORDS.pack('L<*'), result.image
    assert_equal 'STATIC_BUILD_ONLY', result.record['status']
    assert_equal 16, result.record['doorbell']['offset']
    assert_equal 32, result.record['image']['bytes']
    assert_equal Digest::SHA256.hexdigest(result.image), result.record['image']['sha256']
    assert_equal false, result.record['stack']['host_mapping_performed']
  end

  def test_truncated_headers_tables_and_contents
    original = fixture[:bytes]
    [0, 4, 63, 64, 119, TEXT_OFFSET, original.bytesize - 1].each { |length| rejected(original.byteslice(0, length)) }
  end

  def test_wrong_machine_class_endianness_type_or_entry
    [[4, "\x01"], [5, "\x02"], [16, [3].pack('S<')], [18, [62].pack('S<')],
     [24, [BASE + 4].pack('Q<')]].each do |at, value|
      bytes = fixture[:bytes]; bytes[at, value.bytesize] = value; rejected(bytes)
    end
  end

  def test_huge_and_overlapping_table_ranges
    bytes = fixture[:bytes]; bytes[40, 8] = [(1 << 64) - 1].pack('Q<'); rejected(bytes)
    bytes = fixture[:bytes]; bytes[32, 8] = [8].pack('Q<'); rejected(bytes)
    bytes = fixture[:bytes]; bytes[60, 2] = [129].pack('S<'); rejected(bytes)
  end

  def test_relocation_dynamic_nobits_and_tls_sections_reject
    [4, 6, 8, 9, 11].each do |type|
      data = fixture; data[:bytes][data[:shoff] + 2 * 64 + 4, 4] = [type].pack('L<'); rejected(data[:bytes])
    end
    data = fixture; data[:bytes][data[:shoff] + 64 + 8, 8] = [0x406].pack('Q<'); rejected(data[:bytes])
  end

  def test_additional_allocated_or_writable_section_rejects
    [2, 1, 4].each do |flags|
      data = fixture; data[:bytes][data[:shoff] + 3 * 64 + 8, 8] = [flags].pack('Q<'); rejected(data[:bytes])
    end
  end

  def test_writable_load_and_unrepresented_bss_reject
    bytes = fixture[:bytes]; bytes[68, 4] = [7].pack('L<'); rejected(bytes)
    bytes = fixture[:bytes]; bytes[64 + 40, 8] = [4096].pack('Q<'); rejected(bytes)
    bytes = fixture[:bytes]; bytes[64, 4] = [3].pack('L<'); rejected(bytes)
  end

  def test_undefined_common_and_ifunc_symbols_reject
    [0, 0xfff2].each do |section|
      data = fixture; data[:bytes][data[:symoff] + 24 + 6, 2] = [section].pack('S<'); rejected(data[:bytes])
    end
    data = fixture; data[:bytes][data[:symoff] + 24 + 4, 1] = [0x1a].pack('C'); rejected(data[:bytes])
  end

  def test_wrong_stack_and_missing_required_symbol_reject
    data = fixture; data[:bytes][data[:symoff] + 7 * 24 + 8, 8] = [0x10008000].pack('Q<'); rejected(data[:bytes])
    data = fixture; data[:bytes][data[:stroff] + 1, 1] = 'X'; rejected(data[:bytes])
  end

  def test_doorbell_or_prefix_change_rejects
    [2, 3, 4].each do |index|
      bytes = fixture[:bytes]; bytes[TEXT_OFFSET + index * 4, 4] = [0xd503201f].pack('L<'); rejected(bytes)
    end
  end

  def test_symbol_escape_and_string_index_reject
    data = fixture; data[:bytes][data[:symoff] + 2 * 24 + 8, 8] = [BASE + 32].pack('Q<'); rejected(data[:bytes])
    data = fixture; data[:bytes][data[:symoff] + 24, 4] = [0xffffffff].pack('L<'); rejected(data[:bytes])
  end

  def test_image_digest_changes_without_claiming_instruction_safety
    bytes = fixture[:bytes]
    first = INSPECTOR.inspect_bytes(bytes)
    bytes[TEXT_OFFSET, 4] = [0xd4200000].pack('L<')
    second = INSPECTOR.inspect_bytes(bytes)
    refute_equal first.record['image']['sha256'], second.record['image']['sha256']
    assert_equal 'STATIC_BUILD_ONLY', second.record['status']
    assert_includes second.record['not_proven'], 'Control-flow or panic-path correctness'
  end
end

if $PROGRAM_NAME == __FILE__
  abort 'inspector-tests.rb accepts no arguments' unless ARGV.empty?
  suite = RustBootstrapInspectorTests.new
  tests = RustBootstrapInspectorTests.instance_methods(false).grep(/^test_/).sort
  failures = []
  tests.each do |name|
    begin
      suite.public_send(name)
      STDOUT.write("PASS #{name}\n")
    rescue StandardError => error
      failures << name
      STDERR.write("FAIL #{name}: #{error.class}: #{error.message}\n")
    end
  end
  STDOUT.write("#{tests.length} tests, #{suite.assertions} assertions, #{failures.length} failures; synthetic bytes only\n")
  exit(failures.empty? ? 0 : 1)
end
