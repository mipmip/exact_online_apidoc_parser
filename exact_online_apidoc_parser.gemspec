# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exact_online_apidoc_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "exact_online_apidoc_parser"
  spec.version       = ExactOnlineApidocParser::VERSION
  spec.authors       = ["Pim Snel"]
  spec.email         = ["pim@lingewoud.nl"]
  spec.summary       = %q{Parse API documentation from Exact.nl}
  spec.description   = %q{Parse Exact Online API documentation from exact.nl to be used by generators.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
