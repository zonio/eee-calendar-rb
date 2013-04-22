# -*- coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eee/version'

Gem::Specification.new do |spec|
  spec.name          = "eee"
  spec.version       = EEE::VERSION
  spec.authors       = ["Zonio", "Filip Zrůst"]
  spec.email         = ["developers@zonio.net", "filip.zrust@zonio.net"]
  spec.description   = %q{EEE Protocol Wrapper}
  spec.summary       = %q{An abstraction above XML-RPC API of EEE protocol.}
  spec.homepage      = "http://zonio.net/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ri_cal"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
