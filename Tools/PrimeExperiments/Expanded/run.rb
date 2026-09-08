#!/usr/bin/env ruby
require 'json'
require 'digest'

begin
  raise 'usage: ruby run.rb --prompt TEXT --output FRESH_ABSOLUTE_DIRECTORY' unless
    ARGV.length == 4 && ARGV[0] == '--prompt' && ARGV[2] == '--output'
  question, output = ARGV[1], ARGV[3]
  raise 'question must be nonempty UTF-8, at most 4096 bytes' unless
    question.valid_encoding? && question.bytesize.between?(1, 4096) && !question.include?("\0")
  raise 'fresh canonical output directory required' unless output.start_with?('/') &&
    File.expand_path(output) == output && !File.exist?(output) && !File.symlink?(output) &&
    File.realpath(File.dirname(output)) == File.dirname(output)
  base = File.expand_path('../..', __dir__)
  build = JSON.parse(File.read(File.join(base, 'BUILD.json')))
  runtime = File.join(__dir__, 'Runtime')
  Dir.mkdir(output, 0700); Dir.mkdir(File.join(output, 'cache'), 0700)
  env = {'PATH' => '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME' => Dir.home,
    'TMPDIR' => File.join(output, 'cache'), 'HF_HOME' => File.join(output, 'cache'),
    'HF_HUB_OFFLINE' => '1', 'TRANSFORMERS_OFFLINE' => '1', 'HF_HUB_DISABLE_TELEMETRY' => '1',
    'PYTHONDONTWRITEBYTECODE' => '1', 'TOKENIZERS_PARALLELISM' => 'false',
    'MLX_ENABLE_TF32' => '0', 'OMP_NUM_THREADS' => '2'}
  profile = build.fetch('profile')
  request = {'profile' => profile, 'question' => question, 'maximumNewTokens' => 512}
  request_path = File.join(output, 'request.json')
  if profile == 'older_llama'
    command = [File.expand_path('../../../SharedRuntime/python/bin/python3', __dir__),
      File.join(runtime, 'llama-infer.py'), '--request', request_path]
  else
    raise 'unknown native profile' unless %w[pmhnp compositional_v2 latin].include?(profile)
    request.merge!('labRoot' => File.join(runtime, 'model-lab'),
      'appendAnswerPrefix' => profile == 'compositional_v2')
    command = [File.join(runtime, 'PrimeNativeCheckpointExperiment'), '--request', request_path]
  end
  File.write(request_path, JSON.pretty_generate(request) + "\n", mode: 'wx', perm: 0600)
  spec = {'argv' => command, 'environment' => env, 'buildID' => build.fetch('buildID'),
    'runtimeRevision' => 'expanded-01', 'baseBuildSHA256' => Digest::SHA256.file(File.join(base, 'BUILD.json')).hexdigest,
    'question' => question, 'questionSHA256' => Digest::SHA256.hexdigest(question),
    'requestedMaximumNewTokens' => 512, 'trainingPerformed' => false,
    'referenceAnswersProvidedToModel' => false, 'inputTruncationAllowed' => false}
  File.write(File.join(output, 'specification.json'), JSON.pretty_generate(spec) + "\n", mode: 'wx', perm: 0600)
  exec('/usr/bin/ruby', File.join(runtime, 'controller.rb'), output)
rescue StandardError => e
  warn "Expanded experiment refused: #{e.message}"
  exit 1
end
