# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'torigoya_client/version'

Gem::Specification.new do |spec|
  spec.name          = "torigoya_client"
  spec.version       = TorigoyaClient::VERSION
  spec.authors       = ["yutopp"]
  spec.email         = ["yutopp@gmail.com"]
  spec.summary       = %q{A client library for TorigoyaCage}
  spec.description   = %q{This library can control TorigoyaCage}
  spec.homepage      = "http://yutopp.net/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "msgpack"
end
