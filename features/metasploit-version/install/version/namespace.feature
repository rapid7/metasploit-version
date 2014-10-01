Feature: metasploit-version install's 'version.rb' generate proper namespace nesting

  The version.rb file from metasploit-version will generate the appropriately indented nesting for single and multiple
  namespaces with proper conversion of underscored and dashes in the gem name to camel case and separate modules,
  respectively

  Scenario Outline: Top-level namespace
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "<gem_name>"
    And I install latest local "metasploit-version" gem
    And I successfully run `bundle gem <gem_name>`
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
      | single    | lib/single/version.rb    | Single         |
      | two_words | lib/two_words/version.rb | TwoWords       |

  Scenario Outline: Two-level namespace
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "<gem_name>"
    And I install latest local "metasploit-version" gem
    And I successfully run `bundle gem <gem_name>`
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
