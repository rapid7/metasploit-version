module Metasploit
  module Version
    # @example Define gem's VERSION constant using Metasploit::Version::Full
    #   module MyNamespace
    #     module MyGem
    #       # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    #       module Version
    #         extend Metasploit::Version::Full
    #
    #         #
    #         # CONSTANTS
    #         #
    #
    #         # The major version number
    #         MAJOR = 0
    #
    #         # The minor version number, scoped to the {MAJOR} version number.
    #         MINOR = 0
    #
    #         # The patch number, scoped to the {MINOR} version number.
    #         PATCH = 1
    #
    #         # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number.  Will not be defined on master.
    #         PRERELEASE = 'versioning'
    #      end
    #
    #      # The full semantic version.
    #      VERSION = Version.full
    #    end
    #  end
    module Full
      # The full version string, including the `MAJOR`, `MINOR`, `PATCH`, and optionally, the `PRERELEASE` in the
      # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
      #
      # @return [String] '`MAJOR`.`MINOR`.`PATCH`' on master.  '`MAJOR`.`MINOR`.`PATCH`-`PRERELEASE`' on any branch
      #   other than master.
      def full
        version = "#{self::MAJOR}.#{self::MINOR}.#{self::PATCH}"

        if defined? self::PRERELEASE
          version = "#{version}-#{self::PRERELEASE}"
        end

        version
      end
    end
  end
end