# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bb_openstruct/version'

Gem::Specification.new do |spec|
  spec.name          = "bb_openstruct"
  spec.version       = BBOpenstruct::VERSION
  spec.authors       = ["Piotr Szmielew"]
  spec.email         = ["p.szmielew@ava.waw.pl"]

  spec.summary       = %q{Reimplementation of OpenStruct that uses binding object as data store}
  spec.homepage      = "https://github.com/esse/bb_openstruct"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
