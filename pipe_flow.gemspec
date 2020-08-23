# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipe_flow/version'

Gem::Specification.new do |spec|
  spec.name          = 'pipe_flow'
  spec.version       = PipeFlow::VERSION
  spec.required_ruby_version = '>= 2.4.0'
  spec.authors       = ['Matthew Crocco']
  spec.email         = ['matthewcrocco@gmail.com']

  spec.summary       = %(An experimental implementation of pipelines in ruby using a
                         macro-like AST-based approach)
  spec.homepage      = 'https://www.github.com/mattc529/pipe_flow'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'fasterer', '~> 0.4.1'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'pry-byebug', '~> 3.6.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.85'
  spec.add_development_dependency 'rubycritic', '~> 4.5.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'simplecov-console', '~> 0.4.2'
end
