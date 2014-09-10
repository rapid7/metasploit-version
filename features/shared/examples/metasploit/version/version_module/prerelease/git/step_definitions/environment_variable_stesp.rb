Given(/^I unset the environment variable "(.*?)"$/) do |variable|
  set_env(variable, nil)
end