# Metasploit::Version [![Build Status](https://travis-ci.org/rapid7/metasploit-version.svg)](https://travis-ci.org/rapid7/metasploit-version)[![Code Climate](https://codeclimate.com/github/rapid7/metasploit-version.png)](https://codeclimate.com/github/rapid7/metasploit-version)[![Coverage Status](https://coveralls.io/repos/rapid7/metasploit-version/badge.png)](https://coveralls.io/r/rapid7/metasploit-version)[![Dependency Status](https://gemnasium.com/rapid7/metasploit-version.svg)](https://gemnasium.com/rapid7/metasploit-version)[![Gem Version](https://badge.fury.io/rb/metasploit-version.png)](http://badge.fury.io/rb/metasploit-version)

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
          extend Metasploit::Version::Full

          #
          # CONSTANTS
          #

          # The major version number
          MAJOR = 0

          # The minor version number, scoped to the {MAJOR} version number.
          MINOR = 0

          # The patch number, scoped to the {MINOR} version number.
          PATCH = 1

          # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
          PRERELEASE = '<relative-name>'
        end

        # The full semantic version.
        VERSION = Version.full
      end
    end

On a branch such the relative name is the portion after the branch type as in `bug/<relative-name>`,
`chore/<relative-name>`, `feature/<relative-name>`, or `staging/<relative-name>`.  On master, the gem is assumed to
no longer be in prerelease, so `PRERELEASE` should not be defined.  If it is defined, the
`'Metasploit::Version Version Module'` shared example will fail.

### spec_helper.rb

In your `spec_helper.rb`, require the shared examples from `metasploit-version`.

    Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
      require f
    end

### Gem namespace spec

The spec for your gem's namespace `Module` should use the `'Metasploit::Version VERSION constant'` shared example.

    require 'spec_helper'

    describe MyNamespace::MyGem do
      it_should_behave_like 'Metasploit
    end

### Gem Version spec

The spec for your gem's `Version` `Module` defined in the `version.rb` file should use the
`'Metasploit::Version Version Module'` shared example.

    require 'spec_helper'

    describe MyNamespace::MyGem::Version do
      it_should_behave_like 'Metasploit::Version Version Module'
    end

## Contributing

1. Fork it ( http://github.com/[my-github-username]/metasploit-version/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
