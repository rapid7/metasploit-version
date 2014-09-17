Given(/^I unset the environment variable "(.*?)"$/) do |variable|
  # @note This will only work if the consumer of the environment variable treats a blank value for the environment
  #   variable as the same as the environment variable not being set
  #
  # ENV[variable] = nil and ENV.delete(variable) will not stop the parent process's environment variable from
  # propagating to processes called by run_simple, so have to fake unsetting with blank values.
  if RUBY_PLATFORM == 'java'
    warn "Faking unsetting environment variable for JRuby by setting to blank string"
    set_env(variable, '')
  else
    set_env(variable, nil)
  end
end