# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metasploit/version/version'

Gem::Specification.new do |spec|
  spec.name          = 'metasploit-version'
  spec.version       = Metasploit::Version::GEM_VERSION
  spec.authors       = ['Luke Imhoff']
  spec.email         = ['luke_imhoff@rapid7.com']
  spec.summary       = 'Semantic versioning helpers and shared examples'
  spec.description   = "Metasploit::Version::Full for deriving String VERSION from constants in Version module and " \
                       "shared examples: 'Metasploit::Version VERSION constant' to check VERSION and " \
                       "'Metasploit::Version Version Module' to check Version."
  spec.homepage      = 'https://github.com/rapid7/metasploit-version'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency 'metasploit-yard', '~> 1.0'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'redcarpet'

  spec.add_runtime_dependency 'rspec'
end
