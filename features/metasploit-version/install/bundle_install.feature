Feature: metasploit-version install will install dependencies with bundle install

  After `metasploit-version install` adds the `metasploit-version` as a development dependency to the gemspec,
  `metasploit-version install` should run `bundle install` so that `metasploit-version` itself and its dependencies,
  such as `rspec` are installed so that user can immediately run `rake spec`

  Scenario:
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "installed"
    When I run `bundle list`
    Then the output from "bundle list" should not contain "metasploit-version"
    Given I install latest local "metasploit-version" gem
    And I successfully run `bundle gem installed`
    And I cd to "installed"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem installed"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And I successfully run `metasploit-version install --force`
    When I run `bundle list`
    Then the output from "bundle list" should contain "metasploit-version"
    And the output from "bundle list" should contain "rspec"
