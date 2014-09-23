Feature: metasploit-version install adds 'version.rb' to replace default 'version.rb'

  The version.rb file from metasploit-version will follow semver.org and define `MAJOR`, `MINOR`, and `PATCH`.  If on
  a branch, the `PRERELEASE` will also be defined.  Default implementations for `Version.full` and `Version.gem` will
  be provided and `VERSION` and `GEM_VERSION` will be set to the respective method.

  Scenario: No gemspec
    Given a file matching %r<.*\.gemspec> should not exist
    When I run `metasploit-version install`
    Then the output should contain "No gemspec found"
    And the exit status should not be 0

  Scenario Outline: Top-level namespace
    Given I successfully run `bundle gem <gem_name>`
    And I cd to "<gem_name>"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem <gem_name>"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    When I successfully run `metasploit-version install --force`
    Then the file "<version_rb_path>" should contain exactly:
      """
      module <namespace_name>
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
          PATCH = 0

          #
          # Module Methods
          #

          # The full version string, including the {<namespace_name>::Version::MAJOR},
          # {<namespace_name>::Version::MINOR}, {<namespace_name>::Version::PATCH}, and optionally, the
          # `<namespace_name>::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{<namespace_name>::Version::MAJOR}.{<namespace_name>::Version::MINOR}.{<namespace_name>::Version::PATCH}' on master.
          #   '{<namespace_name>::Version::MAJOR}.{<namespace_name>::Version::MINOR}.{<namespace_name>::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"

            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end

            version
          end

          # The full gem version string, including the {<namespace_name>::Version::MAJOR},
          # {<namespace_name>::Version::MINOR}, {<namespace_name>::Version::PATCH}, and optionally, the
          # `<namespace_name>::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{<namespace_name>::Version::MAJOR}.{<namespace_name>::Version::MINOR}.{<namespace_name>::Version::PATCH}'
          #   on master.  '{<namespace_name>::Version::MAJOR}.{<namespace_name>::Version::MINOR}.{<namespace_name>::Version::PATCH}.PRERELEASE'
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
      | gem_name  | version_rb_path          | namespace_name |
      | singleton | lib/singleton/version.rb | Singleton     |
      | two_words | lib/two_words/version.rb | TwoWords      |

  Scenario Outline: Two-level namespace
    Given I successfully run `bundle gem <gem_name>`
    And I cd to "<gem_name>"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem <gem_name>"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    When I successfully run `metasploit-version install --force`
    Then the file "<version_rb_path>" should contain exactly:
      """
      module <parent_module_name>
        module <child_module_name>
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
            PATCH = 0

            #
            # Module Methods
            #

            # The full version string, including the {<parent_module_name>::<child_module_name>::Version::MAJOR},
            # {<parent_module_name>::<child_module_name>::Version::MINOR}, {<parent_module_name>::<child_module_name>::Version::PATCH}, and optionally, the
            # `<parent_module_name>::<child_module_name>::Version::PRERELEASE` in the
            # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
            #
            # @return [String] '{<parent_module_name>::<child_module_name>::Version::MAJOR}.{<parent_module_name>::<child_module_name>::Version::MINOR}.{<parent_module_name>::<child_module_name>::Version::PATCH}' on master.
            #   '{<parent_module_name>::<child_module_name>::Version::MAJOR}.{<parent_module_name>::<child_module_name>::Version::MINOR}.{<parent_module_name>::<child_module_name>::Version::PATCH}-PRERELEASE'
            #   on any branch other than master.
            def self.full
              version = "#{MAJOR}.#{MINOR}.#{PATCH}"

              if defined? PRERELEASE
                version = "#{version}-#{PRERELEASE}"
              end

              version
            end

            # The full gem version string, including the {<parent_module_name>::<child_module_name>::Version::MAJOR},
            # {<parent_module_name>::<child_module_name>::Version::MINOR}, {<parent_module_name>::<child_module_name>::Version::PATCH}, and optionally, the
            # `<parent_module_name>::<child_module_name>::Version::PRERELEASE` in the
            # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
            #
            # @return [String] '{<parent_module_name>::<child_module_name>::Version::MAJOR}.{<parent_module_name>::<child_module_name>::Version::MINOR}.{<parent_module_name>::<child_module_name>::Version::PATCH}'
            #   on master.  '{<parent_module_name>::<child_module_name>::Version::MAJOR}.{<parent_module_name>::<child_module_name>::Version::MINOR}.{<parent_module_name>::<child_module_name>::Version::PATCH}.PRERELEASE'
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
      end

      """

    Examples:
      | gem_name         | version_rb_path                 | parent_module_name | child_module_name |
      | parent-single    | lib/parent/single/version.rb    | Parent             | Single            |
      | parent-two_words | lib/parent/two_words/version.rb | Parent             | TwoWords          |

  Scenario: Prompts for confirmation if --force or --skip is not used
    Given I successfully run `bundle gem prompt`
    And I cd to "prompt"
    When I run `metasploit-version install` interactively
    And I type "y"
    Then the output should contain "conflict  lib/prompt/version.rb"
    And the output should contain "force  lib/prompt/version.rb"

  Scenario: --force will force update version.rb
    Given I successfully run `bundle gem force`
    And I cd to "force"
    When I successfully run `metasploit-version install --force`
    Then the output should contain "force  lib/force/version.rb"

  Scenario: --skip will not update version.rb
    Given I successfully run `bundle gem skip`
    And I cd to "skip"
    When I successfully run `metasploit-version install --skip`
    Then the output should contain "skip  lib/skip/version.rb"

  Scenario: No PRERELEASE on master
    Given I successfully run `bundle gem master`
    And I cd to "master"
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem master"`
    When I successfully run `metasploit-version install --force`
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
          PATCH = 0

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
    When I successfully run `metasploit-version install --force`
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
          PATCH = 0
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