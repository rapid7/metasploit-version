$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'metasploit/version'

Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
  require f
end
