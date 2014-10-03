Feature: metasploit-version install's 'version_spec.rb' catches errors in version.rb when merging branch to master

  The version_spec.rb file from metasploit-version will catch errors if the user fails to update the PRERELEASE
  constant in version.rb to when going from a branch to master.

  Background:
    Given I successfully run `bundle gem branched`
    And I cd to "branched"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem branched"`
    And I successfully run `git checkout -b feature/MSP-1234/metasploit-version`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And I successfully run `metasploit-version install --force --no-bundle-install`
    And I successfully run `rake spec`
    And I successfully run `git add *`
    And I successfully run `git commit --all --message "metasploit-version install"`
    And I successfully run `git checkout master`
    And I successfully run `git merge feature/MSP-1234/metasploit-version`

  Scenario: Merging branch to master without removing PRERELEASE
    Given the file "lib/branched/version.rb" should contain:
      """
          # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version numbers.
          PRERELEASE = 'metasploit-version'
      """
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected Branched::Version::PRERELEASE not to be defined on master
      """
    And the output should contain " 1 failure"

  Scenario: Merging branch to master with removing PRERELEASE
    Given I overwrite "lib/branched/version.rb" with:
      """
      module Branched
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

          #
          # Module Methods
          #

          # The full version string, including the {ImproperlyBranched::Version::MAJOR},
          # {ImproperlyBranched::Version::MINOR}, {ImproperlyBranched::Version::PATCH}, and optionally, the
          # `ImproperlyBranched::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{ImproperlyBranched::Version::MAJOR}.{ImproperlyBranched::Version::MINOR}.{ImproperlyBranched::Version::PATCH}' on master.
          #   '{ImproperlyBranched::Version::MAJOR}.{ImproperlyBranched::Version::MINOR}.{ImproperlyBranched::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {ImproperlyBranched::Version::MAJOR},
          # {ImproperlyBranched::Version::MINOR}, {ImproperlyBranched::Version::PATCH}, and optionally, the
          # `ImproperlyBranched::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{ImproperlyBranched::Version::MAJOR}.{ImproperlyBranched::Version::MINOR}.{ImproperlyBranched::Version::PATCH}'
          #   on master.  '{ImproperlyBranched::Version::MAJOR}.{ImproperlyBranched::Version::MINOR}.{ImproperlyBranched::Version::PATCH}.PRERELEASE'
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
