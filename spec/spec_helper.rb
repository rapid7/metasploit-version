$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# require before 'metasploit/version' so coverage is shown for files required by 'metasploit/version'
require 'simplecov'
require 'codeclimate-test-reporter'
require 'coveralls'

if ENV['TRAVIS'] == 'true'
  formatters = []

  # don't use `CodeClimate::TestReporter.start` as it will overwrite some .simplecov settings
  if CodeClimate::TestReporter.run?
    formatters << CodeClimate::TestReporter::Formatter
  end

  formatters << Coveralls::SimpleCov::Formatter

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    *formatters
  ]
end

require 'metasploit/version'

Dir[Metasploit::Version.root.join('spec', 'support', '**', '*.rb')].each do |f|
  require f
end
