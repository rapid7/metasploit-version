$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# require before 'metasploit/version' so coverage is shown for files required by 'metasploit/version'
require 'simplecov'

require 'metasploit/version'

Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
  require f
end
