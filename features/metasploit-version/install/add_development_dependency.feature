Feature: metasploit-version install adds 'metasploit-version' as a development dependency

  The `metasploit-version install` command will add 'metasploit-version' to the gem's gemspec if it is not already
  added.

  Scenario: No gemspec
    Given a file matching %r<.*\.gemspec> should not exist
    When I run `metasploit-version install`
    Then the output should contain "No gemspec found"
    And the exit status should not be 0

  Scenario: Not added to gemspec
    Given I successfully run `bundle gem metasploit_version_install_development_dependency`
    And I cd to "metasploit_version_install_development_dependency"
    When I successfully run `metasploit-version install --force`
    Then metasploit-version should be development dependency with semantic version restriction in "metasploit_version_install_development_dependency.gemspec"

  Scenario: No semantic version restriction
    Given I successfully run `bundle gem metasploit_version_install_development_dependency`
    And I cd to "metasploit_version_install_development_dependency"
    And I overwrite "metasploit_version_install_development_dependency.gemspec" with:
      """
      # coding: utf-8

      Gem::Specification.new do |spec|
        spec.name          = "metasploit_version_install_development_dependency"
        spec.version       = '0.0.0'
        spec.authors       = ["Luke Imhoff"]
        spec.email         = ["luke_imhoff@rapid7.com"]
        spec.summary       = %q{TODO: Write a short summary. Required.}
        spec.description   = %q{TODO: Write a longer description. Optional.}
        spec.homepage      = ""
        spec.license       = "MIT"

        spec.files         = `git ls-files -z`.split("\x0")
        spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
        spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
        spec.require_paths = ["lib"]

        spec.add_development_dependency "bundler", "~> 1.6"
        spec.add_development_dependency 'metasploit-version'
        spec.add_development_dependency "rake"
      end
      """
    When I successfully run `metasploit-version install --force`
    Then metasploit-version should be development dependency with semantic version restriction in "metasploit_version_install_development_dependency.gemspec"

  Scenario: Semantic version restriction in gemspec
    Given I successfully run `bundle gem metasploit_version_install_development_dependency`
    And I cd to "metasploit_version_install_development_dependency"
    And I overwrite "metasploit_version_install_development_dependency.gemspec" with:
      """
      # coding: utf-8

      Gem::Specification.new do |spec|
        spec.name          = "metasploit_version_install_development_dependency"
        spec.version       = '0.0.0'
        spec.authors       = ["Luke Imhoff"]
        spec.email         = ["luke_imhoff@rapid7.com"]
        spec.summary       = %q{TODO: Write a short summary. Required.}
        spec.description   = %q{TODO: Write a longer description. Optional.}
        spec.homepage      = ""
        spec.license       = "MIT"

        spec.files         = `git ls-files -z`.split("\x0")
        spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
        spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
        spec.require_paths = ["lib"]

        spec.add_development_dependency "bundler", "~> 1.6"
        spec.add_development_dependency 'metasploit-version', '~> 0.0.0'
        spec.add_development_dependency "rake"
      end
      """
    When I successfully run `metasploit-version install --force`
    Then metasploit-version should be development dependency with semantic version restriction in "metasploit_version_install_development_dependency.gemspec"
