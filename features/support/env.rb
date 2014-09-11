# Has to be the first file required so that all other files show coverage information
require 'simplecov'

#
# Standard Library
#

require 'pathname'

#
# Gems
#

require 'aruba/cucumber'
# only does jruby customization if actually in JRuby
require 'aruba/jruby'

Before do |scenario|
  command_name = scenario.name

  # Support scenario outlines (scenarios that have "example" tables)
  if scenario.respond_to?(:scenario_outline)
    command_name = "#{scenario.scenario_outline.name} #{command_name}"
  end

  # Used in simplecov_setup so that each scenario has a different name and their coverage results are merged instead
  # of overwriting each other as 'Cucumber Features'
  set_env('SIMPLECOV_COMMAND_NAME', command_name)

  simplecov_setup_pathname = Pathname.new(__FILE__).expand_path.parent.join('simplecov_setup')
  # set environment variable so child processes will merge their coverage data with parent process's coverage data.
  set_env('RUBYOPT', "-r#{simplecov_setup_pathname} #{ENV['RUBYOPT']}")
end

Before do
  @aruba_timeout_seconds = 10 * 60
end
