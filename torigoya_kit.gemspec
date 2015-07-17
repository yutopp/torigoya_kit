# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'torigoya_kit/version'

Gem::Specification.new do |spec|
  spec.name          = "torigoya_kit"
  spec.version       = TorigoyaKit::VERSION
  spec.authors       = ["yutopp"]
  spec.email         = ["yutopp@gmail.com"]
  spec.summary       = %q{Toolkits for Torigoya}
  spec.description   = %q{This library can control TorigoyaCage}
  spec.homepage      = "https://github.com/yutopp/torigoya_kit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "msgpack"
end
