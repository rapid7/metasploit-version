require 'metasploit/version/full'

module Metasploit
  module Version
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      extend Metasploit::Version::Full

      # The major version number.
      MAJOR = 0
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 0
      # The patch number, scoped to the {MINOR} version number.
      PATCH = 1
      # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number. Will not be defined on master.
      PRERELEASE = 'MSP-9923-port'
    end

    # The full semantic version.
    VERSION = Version.full
  end
end
