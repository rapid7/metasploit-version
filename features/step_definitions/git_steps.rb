fail_on_error = true

Given /^a git repository$/ do
  # git init will fail if account ident it not setup
  if ENV['TRAVIS'] == 'true'
    run_simple('git config --global user.email "cucumber@example.com"')
    run_simple('git config --global user.name "Cucumber"')
  end

  run_simple('git init', fail_on_error)
  path = '.gitignore'
  write_file(path, '')
  run_simple("git add #{path}", fail_on_error)
  run_simple('git commit --message "Initial commit"', fail_on_error)
end

Given /^(\d+) commits$/ do |commits|
  commits = commits.to_i

  commits.times do |commit|
    path = "file#{commit}"
    write_file(path, '')
    run_simple("git add #{path}", fail_on_error)
    run_simple("git commit --message \"Commit #{commit} of #{commits}\"", fail_on_error)
  end
end

Given /^a git checkout of "(.*?)"$/ do |treeish|
  run_simple("git checkout #{treeish}", fail_on_error)
end

Given(/^my git identity is configured$/) do
  # git commit will fail if account ident is not setup
  if ENV['TRAVIS'] == 'true'
    run_simple('git config --local user.email "cucumber@example.com"')
    run_simple('git config --local user.name "Cucumber"')
  end
end