Feature: metasploit-version install conditionally defines PRERELEASE in version.rb

  The version.rb file will define PRERELEASE to the branch's prerelease name when `metasploit-version install` is run on
  a branch, while it will not define PRERELEASE on master.

  Scenario: No PRERELEASE on master
    Given I successfully run `bundle gem master`
    And I cd to "master"
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem master"`
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "lib/master/version.rb" should contain exactly:
      """
      module Master
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

          # The full version string, including the {Master::Version::MAJOR},
          # {Master::Version::MINOR}, {Master::Version::PATCH}, and optionally, the
          # `Master::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{Master::Version::MAJOR}.{Master::Version::MINOR}.{Master::Version::PATCH}' on master.
          #   '{Master::Version::MAJOR}.{Master::Version::MINOR}.{Master::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {Master::Version::MAJOR},
          # {Master::Version::MINOR}, {Master::Version::PATCH}, and optionally, the
          # `Master::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{Master::Version::MAJOR}.{Master::Version::MINOR}.{Master::Version::PATCH}'
          #   on master.  '{Master::Version::MAJOR}.{Master::Version::MINOR}.{Master::Version::PATCH}.PRERELEASE'
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

  Scenario Outline: PRERELEASE on branch
    Given I successfully run `bundle gem branch`
    And I cd to "branch"
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem branch"`
    And I successfully run `git checkout -b <branch>`
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "lib/branch/version.rb" should contain exactly:
      """
      module Branch
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
          PRERELEASE = '<prerelease>'

          #
          # Module Methods
          #

          # The full version string, including the {Branch::Version::MAJOR},
          # {Branch::Version::MINOR}, {Branch::Version::PATCH}, and optionally, the
          # `Branch::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{Branch::Version::MAJOR}.{Branch::Version::MINOR}.{Branch::Version::PATCH}' on master.
          #   '{Branch::Version::MAJOR}.{Branch::Version::MINOR}.{Branch::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {Branch::Version::MAJOR},
          # {Branch::Version::MINOR}, {Branch::Version::PATCH}, and optionally, the
          # `Branch::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{Branch::Version::MAJOR}.{Branch::Version::MINOR}.{Branch::Version::PATCH}'
          #   on master.  '{Branch::Version::MAJOR}.{Branch::Version::MINOR}.{Branch::Version::PATCH}.PRERELEASE'
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

    Examples:
      | branch                      | prerelease    |
      | staging/flood-release       | flood-release |
      | bug/MSP-666/nasty           | nasty         |
      | chore/MSP-1234/recurring    | recurring     |
      | feature/MSP-1337/super-cool | super-cool    |