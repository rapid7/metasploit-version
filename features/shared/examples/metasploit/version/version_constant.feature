Feature: 'Metasploit::Version VERSION constant' shared example

  The 'Metasploit::Version VERSION constant' shared example will check that the described_class for an RSpec *_spec.rb
  file has a VERSION constant equal to described_class::Version.full, which indicates that VERSION is setup to
  use the full module method.

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

    # Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
    gem_specification = Gem::Specification.find_all_by_name('metasploit-version').first

    Dir[File.join(gem_specification.gem_dir, 'spec', 'support', '**', '*.rb')].each do |f|
      require f
    end
    """
    Given a file named "spec/lib/my_namespace/my_gem_spec.rb" with:
    """ruby
    require 'spec_helper'

    RSpec.describe MyNamespace::MyGem do
      it_should_behave_like 'Metasploit::Version VERSION constant'
    end
    """
  Scenario: VERSION is not defined
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
    """ruby
    require 'metasploit/version'

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

          # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
          PRERELEASE = 'prerelease'
        end
      end
    end
    """
    When I run `rspec spec/lib/my_namespace/my_gem_spec.rb --format documentation`
    Then the output should contain "expected MyNamespace::MyGem::VERSION to be defined"
  Scenario: VERSION is not equal to Version.full
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      require 'metasploit/version'

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

            # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
            PRERELEASE = 'prerelease'

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

          VERSION = '7.8.9'
        end
      end
      """
    When I run `rspec spec/lib/my_namespace/my_gem_spec.rb --format documentation`
    Then the output should contain "expected MyNamespace::MyGem::VERSION to equal MyNamespace::MyGem::Version.full"

  Scenario: VERSION is equal to Version.full
    Given a file named "lib/my_namespace/my_gem/version.rb" with:
      """ruby
      require 'metasploit/version'

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

            # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
            PRERELEASE = 'prerelease'

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

          VERSION = Version.full
        end
      end
      """
    Then I successfully run `rspec spec/lib/my_namespace/my_gem_spec.rb --format documentation`
