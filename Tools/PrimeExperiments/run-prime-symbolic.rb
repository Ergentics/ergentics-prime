#!/usr/bin/env ruby
require 'json'
require 'digest'

begin
  raise 'usage: ruby run.rb --request ABS_NATIVE_REQUEST --output FRESH_ABS_DIRECTORY' unless
    ARGV.length == 4 && ARGV[0] == '--request' && ARGV[2] == '--output'
  input, output = ARGV[1], ARGV[3]
  raise 'request must be a canonical file of at most 16 KiB' unless input.start_with?('/') &&
    File.realpath(input) == input && File.file?(input) && File.size(input) <= 16384
  raise 'output must be fresh and absolute' unless output.start_with?('/') &&
    File.expand_path(output) == output && !File.exist?(output) && !File.symlink?(output) &&
    File.realpath(File.dirname(output)) == File.dirname(output)
  bytes = File.binread(input)
  Dir.mkdir(output, 0700); Dir.mkdir(File.join(output, 'cache'), 0700)
  request = File.join(output, 'request.json')
  File.write(request, bytes, mode: 'wx', perm: 0600)
  python = File.expand_path('../SharedRuntime/python/bin/python3', __dir__)
  environment = {'PATH' => '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME' => Dir.home,
    'TMPDIR' => File.join(output, 'cache'), 'HF_HOME' => File.join(output, 'cache'),
    'HF_HUB_OFFLINE' => '1', 'TRANSFORMERS_OFFLINE' => '1', 'HF_HUB_DISABLE_TELEMETRY' => '1',
    'PYTHONDONTWRITEBYTECODE' => '1', 'TOKENIZERS_PARALLELISM' => 'false',
    'MLX_ENABLE_TF32' => '0', 'OMP_NUM_THREADS' => '2'}
  spec = {'argv' => [python, '-B', File.join(__dir__, 'Runtime/infer.py'),
    '--request', request, '--output', File.join(output, 'prediction.json')],
    'environment' => environment, 'buildID' => 'EPM-20260908-0005-prime-symbolic',
    'requestSHA256' => Digest::SHA256.hexdigest(bytes), 'trainingPerformed' => false,
    'inputKind' => 'original_Z8_symbols_no_text_codec'}
  File.write(File.join(output, 'specification.json'), JSON.pretty_generate(spec) + "\n", mode: 'wx', perm: 0600)
  exec('/usr/bin/ruby', File.join(__dir__, 'Runtime/controller.rb'), output)
rescue StandardError => e
  warn "Prime native launch refused: #{e.message}"
  exit 1
end
