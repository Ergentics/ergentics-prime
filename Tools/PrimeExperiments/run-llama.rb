#!/usr/bin/env ruby
require 'json'
require 'digest'
require 'fileutils'

begin
  raise 'usage: ruby run.rb --prompt TEXT --output FRESH_ABSOLUTE_DIRECTORY [--max-tokens N]'  unless
    [4, 6].include?(ARGV.length) && ARGV[0] == '--prompt' && ARGV[2] == '--output' && (ARGV.length == 4 || ARGV[4] == '--max-tokens')
  question, output = ARGV[1], ARGV[3]
  maximum = ARGV.length == 6 ? Integer(ARGV[5], 10) : 256
  raise 'max-tokens must be 1..256' unless (1..256).include?(maximum)
  raise 'question must contain 1..4096 UTF-8 bytes' unless question.valid_encoding? &&
    question.bytesize.between?(1, 4096) && !question.include?("\0")
  raise 'output must be a fresh absolute path' unless output.start_with?('/') &&
    File.expand_path(output) == output && !File.exist?(output) && !File.symlink?(output)
  raise 'output parent must exist and resolve exactly' unless File.realpath(File.dirname(output)) == File.dirname(output)
  build = JSON.parse(File.read(File.join(__dir__, 'BUILD.json')))
  runtime = File.join(__dir__, 'Runtime')
  Dir.mkdir(output, 0700); Dir.mkdir(File.join(output, 'cache'), 0700)
  environment = {'PATH' => '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME' => Dir.home,
    'TMPDIR' => File.join(output, 'cache'), 'HF_HOME' => File.join(output, 'cache'),
    'HF_HUB_OFFLINE' => '1', 'TRANSFORMERS_OFFLINE' => '1', 'HF_HUB_DISABLE_TELEMETRY' => '1',
    'PYTHONDONTWRITEBYTECODE' => '1', 'TOKENIZERS_PARALLELISM' => 'false', 'MLX_ENABLE_TF32' => '0',
    'OMP_NUM_THREADS' => '2'}
  if build['profile'] == 'older_llama'
    python = File.expand_path('../SharedRuntime/python/bin/python3', __dir__)
    command = [python, '-m', 'mlx_lm.generate', '--model', File.join(runtime, 'model'),
      '--prompt', question, '--max-tokens', maximum.to_s, '--temp', '0', '--seed', '0', '--verbose', 'True']
  else
    raise 'unknown native profile' unless %w[pmhnp compositional_v2 latin].include?(build['profile'])
    request = {'profile' => build['profile'], 'question' => question, 'maximumNewTokens' => maximum,
      'labRoot' => File.join(runtime, 'model-lab'), 'appendAnswerPrefix' => false}
    request_path = File.join(output, 'request.json')
    File.write(request_path, JSON.pretty_generate(request) + "\n", mode: 'wx', perm: 0600)
    command = [File.join(runtime, 'PrimeNativeCheckpointExperiment'), '--request', request_path]
  end
  specification = {'argv' => command, 'environment' => environment, 'buildID' => build['buildID'],
    'question' => question, 'questionSHA256' => Digest::SHA256.hexdigest(question),
    'maximumNewTokens' => maximum, 'trainingPerformed' => false, 'referenceAnswersProvidedToModel' => false}
  File.write(File.join(output, 'specification.json'), JSON.pretty_generate(specification) + "\n", mode: 'wx', perm: 0600)
  exec('/usr/bin/ruby', File.join(runtime, 'controller.rb'), output)
rescue StandardError => e
  warn "Experiment launch refused: #{e.message}"
  exit 1
end
