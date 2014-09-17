Feature: 'Metasploit::Version Version Module' shared example in pull request build on Travis-CI

  The 'Metasploit::Version Version Module' shared example won't check PRERELEASE for pull request builds on Travis-CI
  because the code is expected to have PRERELEASE set to the value appropriate to the source branch and not the
  destination branch being built by the pull request build.

  Background:
    Given I unset the environment variable "TRAVIS_BRANCH"
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

    Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
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
    Given I set the environment variables to:
      | variable      | value  |
      | TRAVIS_BRANCH | master |

 Scenario: PRERELEASE set to source branch relative name
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
          PRERELEASE = 'source-branch-relative-name'

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
    Given I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | true  |
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain:
      """
            PRERELEASE
              is not defined (PENDING: PRERELEASE can only be set appropriately for a merge by merging to the target branch and then updating PRERELEASE on the target branch before committing and/or pushing to github and travis-ci.)
      """
