Feature: metasploit-version install's <namespace>_spec.rb uses 'Metasploit::Version GEM_VERSION constant' shared example

  The <namespace>_spec.rb will check that GEM_VERSION is defined correctly using the
  'Metasploit::Version GEM_VERSION constant' shared example.

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

  Scenario: GEM_VERSION is not defined
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

        # (see Version.full)
        VERSION = Version.full
      end
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected NamespaceSpec::GEM_VERSION to be defined
      """
    And the output should contain:
      """
           NameError:
             uninitialized constant NamespaceSpec::GEM_VERSION
      """
    And the output should contain " 2 failures"

  Scenario: GEM_VERSION is not equal to Version.gem
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

        # (see Version.full)
        GEM_VERSION = Version.full

        # (see Version.full)
        VERSION = Version.full
      end
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected NamespaceSpec::GEM_VERSION to equal NamespaceSpec::Version.gem
      """
    And the output should contain " 1 failure"
