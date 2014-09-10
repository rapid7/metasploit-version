Feature: 'Metasploit::Version Version Module' shared example in detached head build locally

  The 'Metasploit::Version Version Module' shared example will not check that the described_class for an RSpec *_spec.rb
  file defines PRERELEASE when the git repository is in a detached head state, such as when checking out a SHA and it
  does not correspond to a pre-existing branch or tag.

  Background:
    Given I unset the environment variable "TRAVIS_BRANCH"
    Given a git repository
    And 2 commits
    And a git checkout of "HEAD^"
    And a file named "lib/my_namespace/my_gem.rb" with:
      """ruby
      require 'my_namespace/my_gem/version'

      module MyNamespace
        module MyGem
        end
      end
      """
    And a file named "spec/spec_helper.rb" with:
      """ruby
      require 'metasploit/version'
      require 'my_namespace/my_gem'

      Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
        require f
      end
      """
    And a file named "spec/lib/my_namespace/my_gem/version_spec.rb" with:
      """ruby
      require 'spec_helper'

      RSpec.describe MyNamespace::MyGem::Version do
        it_should_behave_like 'Metasploit::Version Version Module'
      end
      """

  Scenario: PRERELEASE defined
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
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain:
      """
      Pending:
        MyNamespace::MyGem::Version it should behave like Metasploit::Version Version Module CONSTANTS PRERELEASE has an abbreviated reference that can be parsed for prerelease
          # Cannot determine branch name in detached HEAD state.  Set TRAVIS_BRANCH to supply branch name
      """
