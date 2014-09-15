#
# Standard Library
#

require 'pathname'

#
# Project
#

require 'metasploit/version/version'

# Namespace used across all metasploit gems
module Metasploit
  # Namespace for this gem.
  module Version
    autoload :Branch, 'metasploit/version/branch'
  end
end
