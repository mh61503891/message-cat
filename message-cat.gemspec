lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'message-cat/version'

Gem::Specification.new do |spec|
  spec.name          = 'message-cat'
  spec.version       = MessageCat::VERSION
  spec.authors       = ['Masayuki Higashino']
  spec.email         = ['mh.on.web@gmail.com']
  spec.summary       = 'MUA'
  spec.description   = 'MUA'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.1'
  spec.add_dependency 'mail'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'colorize'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
end
