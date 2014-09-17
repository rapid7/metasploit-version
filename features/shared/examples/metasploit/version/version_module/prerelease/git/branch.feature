Feature: 'Metasploit::Version Version Module' shared example in branch build on Travis-CI

  The 'Metasploit::Version Version Module' shared example will check that the described_class for an RSpec *_spec.rb
  file defines PRERELEASE to match the relative name of branch.

  Background:
    Given I unset the environment variable "TRAVIS_BRANCH"
    Given I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    Given a git repository
    And 2 commits
    Given a file named "lib/my_namespace/my_gem.rb" with:
      """ruby
      require 'my_namespace/my_gem/version'

      module MyNamespace
        module MyGem
        end
      end
      """
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      require 'metasploit/version'
      require 'my_namespace/my_gem'

      # Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
      gem_specification = Gem::Specification.find_all_by_name('metasploit-version').first

      Dir[File.join(gem_specification.gem_dir, 'spec', 'support', '**', '*.rb')].each do |f|
        require f
      end
      """
    Given a file named "spec/lib/my_namespace/my_gem/version_spec.rb" with:
      """ruby
      require 'spec_helper'

      RSpec.describe MyNamespace::MyGem::Version do
        it_should_behave_like 'Metasploit::Version Version Module'
      end
      """

  Scenario Outline: PRERELEASE defined as branch relative name
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # CONSTANTS
            #

            # The major version number
            MAJOR = 1

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2

            # The patch number, scoped to the {MINOR} version number
            PATCH = 3

            # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
            PRERELEASE = '<prerelease>'

            # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch
            #   other than master.
            def self.full
              version = "#{MAJOR}.#{MINOR}.#{PATCH}"

              if defined? PRERELEASE
                version = "#{version}-#{PRERELEASE}"
              end

              version
            end

            # The full gem version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}.{PRERELEASE}' on any branch
            #   other than master.
            def self.gem
              full.gsub('-', '.pre.')
            end
          end
        end
      end
      """
    And a git checkout of "-b <branch>"
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain:
      """
            PRERELEASE
              matches the <type> branch's name
      """

    Examples:
      | type    | prerelease   | branch                      |
      | bug     | nasty        | bug/MSP-1234/nasty          |
      | feature | super-cool   | feature/MSP-1234/super-cool |
      | staging | rocket-motor | staging/rocket-motor        |

  Scenario Outline: PRERELEASE not defined
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # CONSTANTS
            #

            # The major version number
            MAJOR = 1

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2

            # The patch number, scoped to the {MINOR} version number
            PATCH = 3

            # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch
            #   other than master.
            def self.full
              version = "#{MAJOR}.#{MINOR}.#{PATCH}"

              if defined? PRERELEASE
                version = "#{version}-#{PRERELEASE}"
              end

              version
            end

            # The full gem version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}.{PRERELEASE}' on any branch
            #   other than master.
            def self.gem
              full.gsub('-', '.pre.')
            end
          end
        end
      end
      """
    And a git checkout of "-b <branch>"
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain "MyNamespace::MyGem::Version it should behave like Metasploit::Version Version Module CONSTANTS PRERELEASE matches the <type> branch's name"
    And the output should contain:
      """
             expected MyNamespace::MyGem::Version::PRERELEASE to be defined.
             Add the following to MyNamespace::MyGem::Version:
      """
    # Can't do a continuous multiline string because editors will truncate whitespace in blank line and it won't match
    # whitespace in rspec output.
    And the output should contain:
      """
                 # The prerelease version, scoped to the {PATCH} version number.
                 PRERELEASE = <prerelease>
      """

    Examples:
      | type    | prerelease   | branch                      |
      | bug     | nasty        | bug/MSP-1234/nasty          |
      | feature | super-cool   | feature/MSP-1234/super-cool |
      | staging | rocket-motor | staging/rocket-motor        |

  Scenario Outline: Story branch without a story ID
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
    """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # CONSTANTS
            #

            # The major version number
            MAJOR = 1

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2

            # The patch number, scoped to the {MINOR} version number.
            PATCH = 3

            # The prerelease version, scoped to the {PATCH} version number.
            PRERELEASE = '<prerelease>'

            # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch
            #   other than master.
            def self.full
              version = "#{MAJOR}.#{MINOR}.#{PATCH}"

              if defined? PRERELEASE
                version = "#{version}-#{PRERELEASE}"
              end

              version
            end

            # The full gem version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
            # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
            #
            # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}.{PRERELEASE}' on any branch
            #   other than master.
            def self.gem
              full.gsub('-', '.pre.')
            end
          end
        end
      end
      """
    And a git checkout of "-b <branch>"
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain:
      """
      Do not know how to parse "<branch>" for PRERELEASE
      """

    Examples:
      | prerelease | branch             |
      | nasty      | bug/nasty          |
      | recurring  | chore/recurring    |
      | super-cool | feature/super-cool |
