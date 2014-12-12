Feature: metasploit-version install should add CHANGELOG.md

  `metasploit-version install` should generate CHANGELOG.md which details the Enhancements, Bug Fixes, Deprecations and
  Incompatible Changes for each release version.  Items in each category should link to the associated PR with a
  user-facing summary and contributor credit using their github handle.

  See https://github.com/intridea/hashie/blob/master/CHANGELOG.md for an example of this item format and
  https://github.com/elixir-lang/elixir/blob/e38f960d7edbf564c8e1b44bd2266ad9eaf6a453/CHANGELOG.md for an example of the
  category breakdown.

  Scenario:
    Given I successfully run `bundle gem changed`
    And I cd to "changed"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem changed"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "CHANGELOG.md" should contain exactly:
      """
      # Next Release

      * Enhancements
      * Bug Fixes
      * Deprecations
      * Incompatible Changes
      """
