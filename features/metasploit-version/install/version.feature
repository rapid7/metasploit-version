Feature: metasploit-version install adds 'version.rb' to replace default 'version.rb'

  The version.rb file from metasploit-version will follow semver.org and define `MAJOR`, `MINOR`, and `PATCH`.  If on
  a branch, the `PRERELEASE` will also be defined.  Default implementations for `Version.full` and `Version.gem` will
  be provided and `VERSION` and `GEM_VERSION` will be set to the respective method.

  Scenario: No gemspec
    Given a file matching %r<.*\.gemspec> should not exist
    When I run `metasploit-version install`
    Then the output should contain "No gemspec found"
    And the exit status should not be 0
