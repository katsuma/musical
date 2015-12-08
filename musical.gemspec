# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'musical/version'

Gem::Specification.new do |spec|
  spec.name          = "musical"
  spec.version       = Musical::VERSION
  spec.authors       = ["ryo katsuma"]
  spec.email         = ["katsuma@gmail.com"]
  spec.description   = %q{musical is a simple tool for your favorite DVD. You can rip vob file by DVD chapter, convert it to wav file and add it to your iTunes library.}
  spec.summary       = %q{A simple rip, encode and iTunes library tool for your favorite DVD}
  spec.homepage      = "http://github.com/katsuma/musical"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.3.2"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "rb-fsevent", "~> 0.9.4"
  spec.add_development_dependency "guard", "~> 2.6.1"
  spec.add_development_dependency "guard-rspec", "~> 4.3.1"
  spec.add_development_dependency "growl", "~> 1.0.3"
  spec.add_development_dependency "fakefs", "~> 0.5.3"
  spec.add_development_dependency "simplecov", "~> 0.9.0"
  spec.add_development_dependency "coveralls", "~> 0.7.1"
  spec.add_runtime_dependency "ruby-progressbar", ">= 1.5.1"
  spec.add_runtime_dependency "trollop", ">= 2.0"
  spec.add_runtime_dependency "itunes-client", "~> 0.2.0"
end
