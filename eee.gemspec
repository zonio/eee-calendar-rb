# -*- coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eee/version'

Gem::Specification.new do |spec|
  spec.name          = "eee"
  spec.version       = EEE::VERSION
  spec.authors       = ["Zonio", "Filip Zrůst"]
  spec.email         = ["developers@zonio.net", "filip.zrust@zonio.net"]
  spec.description   = %q{EEE (Easy Event Exchange) is an open client-server protocol for exchange of calendar data.}
  spec.summary       = %q{Wrapper around both ESClient (client to server) and ESServer (server to server) method calls. Additionally, convenient scenario runner (making multiple method calls using one TCP channel) and test helpers are provided.}
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
