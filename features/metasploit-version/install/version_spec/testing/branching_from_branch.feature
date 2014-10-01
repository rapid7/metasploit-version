Feature: metasploit-version install's version_spec.rb catches errors with PRERELEASE when branching from another branch

  The version_spec.rb file from metasploit-version will catch errors if the user fails to update the PRERELEASE
  constant in version.rb to when going from one branch to another.

  Background:
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "double_branched"
    And I install latest local "metasploit-version" gem
    And I successfully run `bundle gem double_branched`
    And I cd to "double_branched"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem double_branched"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And I successfully run `metasploit-version install --force`
    And I successfully run `rake spec`
    And I successfully run `git add *`
    And I successfully run `git commit --all --message "metasploit-version install"`
    And I successfully run `git checkout -b feature/MSP-1337/super-cool`
    And I overwrite "lib/double_branched/version.rb" with:
      """
      module DoubleBranched
        # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
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

          # The full version string, including the {DoubleBranched::Version::MAJOR},
          # {DoubleBranched::Version::MINOR}, {DoubleBranched::Version::PATCH}, and optionally, the
          # `DoubleBranched::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}' on master.
          #   '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {DoubleBranched::Version::MAJOR},
          # {DoubleBranched::Version::MINOR}, {DoubleBranched::Version::PATCH}, and optionally, the
          # `DoubleBranched::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}'
          #   on master.  '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}.PRERELEASE'
          #   on any branch other than master.
          def self.gem
            full.gsub('-', '.pre.')
          end
        end

        # (see Version.gem)
        GEM_VERSION = Version.gem

        # (see Version.full)
        VERSION = Version.full
      end

      """
    And I successfully run `rake spec`
    And I successfully run `git checkout -b bug/MSP-666/needed-for-super-cool`

  Scenario: With changing PRERELEASE
    Given I overwrite "lib/double_branched/version.rb" with:
      """
      module DoubleBranched
        # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
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
          PRERELEASE = 'needed-for-super-cool'

          #
          # Module Methods
          #

          # The full version string, including the {DoubleBranched::Version::MAJOR},
          # {DoubleBranched::Version::MINOR}, {DoubleBranched::Version::PATCH}, and optionally, the
          # `DoubleBranched::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}' on master.
          #   '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {DoubleBranched::Version::MAJOR},
          # {DoubleBranched::Version::MINOR}, {DoubleBranched::Version::PATCH}, and optionally, the
          # `DoubleBranched::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}'
          #   on master.  '{DoubleBranched::Version::MAJOR}.{DoubleBranched::Version::MINOR}.{DoubleBranched::Version::PATCH}.PRERELEASE'
          #   on any branch other than master.
          def self.gem
            full.gsub('-', '.pre.')
          end
        end

        # (see Version.gem)
        GEM_VERSION = Version.gem

        # (see Version.full)
        VERSION = Version.full
      end

      """
    Then I successfully run `rake spec`

  Scenario: Without changing PRERELEASE
    Given the file "lib/double_branched/version.rb" should contain:
      """
          # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version numbers.
          PRERELEASE = 'super-cool'
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected: "needed-for-super-cool"
                  got: "super-cool"
      """
    And the output should contain " 1 failure"
