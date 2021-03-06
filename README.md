# Metasploit::Version [![Build Status](https://travis-ci.org/rapid7/metasploit-version.svg)](https://travis-ci.org/rapid7/metasploit-version)[![Code Climate](https://codeclimate.com/github/rapid7/metasploit-version.png)](https://codeclimate.com/github/rapid7/metasploit-version)[![Coverage Status](https://coveralls.io/repos/rapid7/metasploit-version/badge.png?branch=feature%2FMSP-9923-port)](https://coveralls.io/r/rapid7/metasploit-version?branch=feature%2FMSP-9923-port)[![Dependency Status](https://gemnasium.com/rapid7/metasploit-version.svg)](https://gemnasium.com/rapid7/metasploit-version)[![Inline docs](http://inch-ci.org/github/rapid7/metasploit-version.svg?branch=master)](http://inch-ci.org/github/rapid7/metasploit-version)[![Gem Version](https://badge.fury.io/rb/metasploit-version.png)](http://badge.fury.io/rb/metasploit-version)[![PullReview stats](https://www.pullreview.com/github/rapid7/metasploit-version/badges/feature/MSP-9923-port.svg?)](https://www.pullreview.com/github/rapid7/metasploit-version/reviews/feature/MSP-9923-port)

Metasploit::Version allows your gem to declare the pieces of its [semantic version](semver.org) as constant and for
your `VERSION` `String` to be automatically derived from those constants.  Shared examples are available to test that
the `PRERELEASE` `String` matches the expected pattern of using the branch relative name and being undefined on master.

## Installation

Add this line to your application's Gemfile:

    gem 'metasploit-version'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metasploit-version

## Usage

### Gem version.rb

Your gem's version.rb file should have a `Version` `Module` that defines the parts of the semantic version and
`extend Metasploit::Version::Full`.  Then, `VERSION` in your gem's top-level namespace `Module` can be set to
`Version.full`

    module MyNamespace
      module MyGem
        # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
        module Version
          #
          # CONSTANTS
          #

          # The major version number
          MAJOR = 0

          # The minor version number, scoped to the {MAJOR} version number.
          MINOR = 0

          # The patch number, scoped to the {MINOR} version number.
          PATCH = 1

          # The prerelease version, scoped to the {PATCH} version number.
          PRERELEASE = '<relative-name>'
          
          #
          # Module Methods
          #
    
          # The full version string, including the {MyNamespace::MyGem::Version::MAJOR},
          # {MyNamespace::MyGem::Version::MINOR}, {MyNamespace::MyGem::Version::PATCH}, and optionally, the
          # `MyNamespace::MyGem::Version::PRERELEASE` in the
          # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
          #
          # @return [String] '{MyNamespace::MyGem::Version::MAJOR}.{MyNamespace::MyGem::Version::MINOR}.{MyNamespace::MyGem::Version::PATCH}'
          #   on master.  '{MyNamespace::MyGem::Version::MAJOR}.{MyNamespace::MyGem::Version::MINOR}.{MyNamespace::MyGem::Version::PATCH}-PRERELEASE'
          #   on any branch other than master.
          def self.full
            version = "#{MAJOR}.#{MINOR}.#{PATCH}"
    
            if defined? PRERELEASE
              version = "#{version}-#{PRERELEASE}"
            end
    
            version
          end
    
          # The full gem version string, including the {MyNamespace::MyGem::Version::MAJOR},
          # {MyNamespace::MyGem::Version::MINOR}, {MyNamespace::MyGem::Version::PATCH}, and optionally, the
          # `MyNamespace::MyGem::Version::PRERELEASE` in the
          # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
          #
          # @return [String] '{MyNamespace::MyGem::Version::MAJOR}.{MyNamespace::MyGem::Version::MINOR}.{MyNamespace::MyGem::Version::PATCH}'
          #   on master.  '{MyNamespace::MyGem::Version::MAJOR}.{MyNamespace::MyGem::Version::MINOR}.{MyNamespace::MyGem::Version::PATCH}.PRERELEASE'
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

On a branch such the relative name is the portion after the branch type as in `bug/<relative-name>`,
`chore/<relative-name>`, `feature/<relative-name>`, or `staging/<relative-name>`.  On master, the gem is assumed to
no longer be in prerelease, so `PRERELEASE` should not be defined.  If it is defined, the
`'Metasploit::Version Version Module'` shared example will fail.

### spec_helper.rb

In your `spec_helper.rb`, require the shared examples from `metasploit-version`.

    # Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
    gem_specification = Gem::Specification.find_all_by_name('metasploit-version').first

    Dir[File.join(gem_specification.gem_dir, 'spec', 'support', '**', '*.rb')].each do |f|
      require f
    end

### Gem namespace spec

The spec for your gem's namespace `Module` should use the `'Metasploit::Version VERSION constant'` shared example.

    require 'spec_helper'

    describe MyNamespace::MyGem do
      it_should_behave_like 'Metasploit::Version VERSION constant'
      it_should_behave_like 'Metasploit::Version GEM_VERSION constant'
    end

### Gem Version spec

The spec for your gem's `Version` `Module` defined in the `version.rb` file should use the
`'Metasploit::Version Version Module'` shared example.

    require 'spec_helper'

    describe MyNamespace::MyGem::Version do
      it_should_behave_like 'Metasploit::Version Version Module'
    end

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

