# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prime_service/version'

Gem::Specification.new do |spec|
  spec.name          = "prime_service"
  spec.version       = PrimeService::VERSION
  spec.authors       = ["Tilo Dietrich"]
  spec.email         = ["tilodietrich@posteo.de"]
  spec.summary       = "A gem for Service Objects."
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 4.0"
  spec.add_dependency "virtus",      "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
