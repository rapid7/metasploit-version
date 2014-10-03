Feature: metasploit-version install's <namespace>_spec.rb uses 'Metasploit::Version VERSION constant' shared example

  The <namespace>_spec.rb will check that VERSION is defined correctly using the 'Metasploit::Version VERSION constant'
  shared example.

  Background:
    Given I successfully run `bundle gem namespace_spec`
    And I cd to "namespace_spec"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem namespace_spec"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And I successfully run `metasploit-version install --force --no-bundle-install`
    And I successfully run `git add *`
    And I successfully run `git commit --all --message "metasploit-version install"`
    And I successfully run `git checkout -b feature/MSP-1337/super-cool`

  Scenario: VERSION is not defined
    # Have to ensure that gemspec doesn't reference the undefined NamespaceSpec::VERSION or rake spec won't even run
    # due to NameError when gemspec is loaded by bundler.
    Given I overwrite "namespace_spec.gemspec" with:
      """
      # coding: utf-8

      Gem::Specification.new do |spec|
        spec.name          = "add_development_dependency"
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
    And I overwrite "lib/namespace_spec/version.rb" with:
      """
      module NamespaceSpec
        module Version
          #
          # CONSTANTS
          #

          # The major version number.
          MAJOR = 0
          # The minor version number, scoped to the {MAJOR} version number.
          MINOR = 0
          # The patch version number, scoped to the {MAJOR} and {MINOR} version numbers.
          PATCH = 1
          # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version numbers.
          PRERELEASE = 'super-cool'

          #
          # Module Methods
          #
          
          # The full version string, including the {NamespaceSpec::Version::MAJOR},
          # {NamespaceSpec::Version::MINOR}, {NamespaceSpec::Version::PATCH}, and optionally, the
          # `NamespaceSpec::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}' on master.
          #   '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {NamespaceSpec::Version::MAJOR},
          # {NamespaceSpec::Version::MINOR}, {NamespaceSpec::Version::PATCH}, and optionally, the
          # `NamespaceSpec::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}'
          #   on master.  '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}.PRERELEASE'
          #   on any branch other than master.
          def self.gem
            full.gsub('-', '.pre.')
          end
        end

        # (see Version.gem)
        GEM_VERSION = Version.gem
      end
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected NamespaceSpec::VERSION to be defined
      """
    # On MRI and JRuby, the error is "uninitialized constant NamespaceSpace::VERSION", but on Rubinius the error is
    # "Missing or uninitialized constant: NamespaceSpec::VERSION", so have to use match
    And the output should match /uninitialized constant.*NamespaceSpec::VERSION/
    And the output should contain " 2 failures"

  Scenario: VERSION is not equal to Version.full
    Given I overwrite "lib/namespace_spec/version.rb" with:
      """
      module NamespaceSpec
        module Version
          #
          # CONSTANTS
          #

          # The major version number.
          MAJOR = 0
          # The minor version number, scoped to the {MAJOR} version number.
          MINOR = 0
          # The patch version number, scoped to the {MAJOR} and {MINOR} version numbers.
          PATCH = 1
          # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version numbers.
          PRERELEASE = 'super-cool'

          #
          # Module Methods
          #

          # The full version string, including the {NamespaceSpec::Version::MAJOR},
          # {NamespaceSpec::Version::MINOR}, {NamespaceSpec::Version::PATCH}, and optionally, the
          # `NamespaceSpec::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}' on master.
          #   '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {NamespaceSpec::Version::MAJOR},
          # {NamespaceSpec::Version::MINOR}, {NamespaceSpec::Version::PATCH}, and optionally, the
          # `NamespaceSpec::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}'
          #   on master.  '{NamespaceSpec::Version::MAJOR}.{NamespaceSpec::Version::MINOR}.{NamespaceSpec::Version::PATCH}.PRERELEASE'
          #   on any branch other than master.
          def self.gem
            full.gsub('-', '.pre.')
          end
        end

        # (see Version.gem)
        GEM_VERSION = Version.gem

        VERSION = '1.2.3'
      end
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected NamespaceSpec::VERSION to equal NamespaceSpec::Version.full
      """
    And the output should contain " 1 failure"
