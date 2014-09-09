Feature: 'Metasploit::Version Version Module' shared example

  The 'Metasploit::Version Version Module' shared example will check that the described_class for an RSpec *_spec.rb
  file defined the MAJOR, MINOR, and PATCH constants as Integers; the full module method combines those constants
  (and PRERELEASE when present) into a version string; and

  Background:
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

  Scenario: With String MAJOR, MINOR, and PATCH
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # Constants
            #

            # The major version number
            MAJOR = '1'

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = '2'

            # The patch number, scoped to the {MINOR} version number
            PATCH = '3'

            #
            # Module Methods
            #

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
      expected "1" to be a kind of Integer
      """
       And the output should contain:
      """
      expected "2" to be a kind of Integer
      """
       And the output should contain:
      """
      expected "3" to be a kind of Integer
      """

  Scenario: Without full method, example implementation is given
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # Constants
            #

            # The major version number
            MAJOR = 1

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2

            # The patch number, scoped to the {MINOR} version number
            PATCH = 3
          end
        end
      end
      """
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    # Need to break up the expected message due to blank lines in expected output
    Then the output should contain:
      """
             expected MyNamespace::MyGem::Version to define self.full().
             Add the following to MyNamespace::MyGem::Version
      """
    And the output should contain:
      """
                 # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
                 # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
                 #
                 # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch
                 #   other than master.
                 def self.full
                   version = "#{MAJOR}.#{MINOR}.#{PATCH}"
      """
    And the output should contain:
      """
                   if defined? PRERELEASE
                     version = "#{version}-#{PRERELEASE}"
                   end
      """
    And the output should contain:
      """
                   version
                end
      """

  Scenario: Without gem method, example implementation is given
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # Constants
            #

            # The major version number
            MAJOR = 1

            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2

            # The patch number, scoped to the {MINOR} version number
            PATCH = 3

            #
            # Module Methods
            #

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
          end
        end
      end
      """
    When I run `rspec spec/lib/my_namespace/my_gem/version_spec.rb --format documentation`
    Then the output should contain "Add the following to MyNamespace::MyGem::Version:"
    And the output should contain:
      """
                # The full gem version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
                # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
                #
                # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}.{PRERELEASE}' on any branch
                #   other than master.
                def self.gem
                  full.gsub('-', '.pre.')
                end
      """
  Scenario: With integer MAJOR, MINOR, PATCH and both full and gem methods
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      module MyNamespace
        module MyGem
          module Version
            #
            # Constants
            #

            # The major version number
            MAJOR = 1
            # The minor version number, scoped to the {MAJOR} version number.
            MINOR = 2
            # The patch number, scoped to the {MINOR} version number
            PATCH = 3

            #
            # Module Methods
            #

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
          CONSTANTS
            MAJOR
              should be a kind of Integer
            MINOR
              should be a kind of Integer
            PATCH
              should be a kind of Integer
      """
    And the output should contain:
      """
          full
            with PRERELEASE defined
              is <MAJOR>.<MINOR>.<PATCH>-<PRERELEASE>
            without PRERELEASE defined
              is <MAJOR>.<MINOR>.<PATCH>
          gem
            replaces '-' with '.pre.' to be compatible with rubygems 1.8.6
      """
