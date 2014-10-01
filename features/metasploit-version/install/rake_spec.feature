Feature: metasploit-version install will setup rspec and rake spec

  metasploit-version will call setup `spec/spec_helper.rb` and the `Rakefile` so that the user can run `rake spec` after
  `metasploit-version install` completes

  Background:
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "specced"
    And I install latest local "metasploit-version" gem
    And I successfully run `bundle gem specced`
    And I cd to "specced"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem specced"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    And I successfully run `metasploit-version install --force`

  Scenario: spec is a listed task
    When I run `rake -T`
    Then the output should contain "rake spec"

  Scenario: `rake spec` runs without error
    When I successfully run `rake spec`
    Then the output should contain "0 failures"

  Scenario: `rake` runs `rake spec` by default
    When I successfully run `rake`
    Then the output should contain "0 failures"
