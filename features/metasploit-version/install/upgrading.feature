Feature: metasploit-version install should add UPGRADING.md

  `metasploit-version install` should generate UPGRADING.md which includes any information needed by downstream
  consumers of the gem when upgrading to handle Deprecations or Incompatible Changes.

  Scenario:
    Given I successfully run `bundle gem upgraded`
    And I cd to "upgraded"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem upgraded"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "UPGRADING.md" should contain:
      """
      No Deprecations or Incompatible Changes have been introduced at this time
      """
