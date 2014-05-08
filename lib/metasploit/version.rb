#
# Standard Library
#

require 'pathname'

#
# Project
#

require 'metasploit/version/version'

module Metasploit
  # Namespace for this gem.
  module Version
    # The root of the `metasploit-version` gem file system.
    #
    # @return [Pathname]
    def self.root
      @root ||= Pathname.new(__FILE__).parent.parent.parent
    end
  end
end
