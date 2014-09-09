fail_on_error = true

Given /^a git repository$/ do
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