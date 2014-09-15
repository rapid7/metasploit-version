module Metasploit
  module Version
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      #
      # Constants
      #

      # The major version number.
      MAJOR = 0
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 1
      # The patch number, scoped to the {MINOR} version number.
      PATCH = 0
      # The prerelease version, scoped to the {PATCH} version number.
      PRERELEASE = 'metasploit-yard'

      #
      # Module Methods
      #

      # The full version string, including the {Metasploit::Version::Version::MAJOR},
      # {Metasploit::Version::Version::MINOR}, {Metasploit::Version::Version::PATCH}, and optionally, the
      # `Metasploit::Version::Version::PRERELEASE` in the
      # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
      #
      # @return [String] '{Metasploit::Version::Version::MAJOR}.{Metasploit::Version::Version::MINOR}.{Metasploit::Version::Version::PATCH}' on master.
      #   '{Metasploit::Version::Version::MAJOR}.{Metasploit::Version::Version::MINOR}.{Metasploit::Version::Version::PATCH}-PRERELEASE'
      #   on any branch other than master.
      def self.full
        version = "#{MAJOR}.#{MINOR}.#{PATCH}"

        if defined? PRERELEASE
          version = "#{version}-#{PRERELEASE}"
        end

        version
      end

      # The full gem version string, including the {Metasploit::Version::Version::MAJOR},
      # {Metasploit::Version::Version::MINOR}, {Metasploit::Version::Version::PATCH}, and optionally, the
      # `Metasploit::Version::Version::PRERELEASE` in the
      # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
      #
      # @return [String] '{Metasploit::Version::Version::MAJOR}.{Metasploit::Version::Version::MINOR}.{Metasploit::Version::Version::PATCH}'
      #   on master.  '{Metasploit::Version::Version::MAJOR}.{Metasploit::Version::Version::MINOR}.{Metasploit::Version::Version::PATCH}.PRERELEASE'
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
