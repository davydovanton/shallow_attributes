# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shallow_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "shallow_attributes"
  spec.version       = ShallowAttributes::VERSION
  spec.authors       = ["Anton Davydov"]
  spec.email         = ["antondavydov.o@gmail.com"]

  spec.summary       = %q{Attributes for Plain Old Ruby Objects}
  spec.description   = %q{Attributes for Plain Old Ruby Objects}
  spec.homepage      = "https://github.com/davydovanton/shallow_attributes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "dry-types", "~> 0.11"
end
