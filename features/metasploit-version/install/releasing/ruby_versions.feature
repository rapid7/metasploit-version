Feature: metasplopit install should add RELEASING.md that handles multiple ruby versions

  `metasploit-version` install should default to release instructions for MRI `ruby` and `jruby` with the ability to
  override this default.

  Background:
    Given I successfully run `bundle gem released`
    And I cd to "released"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem released"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |

  Scenario: Default ruby versions
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "RELEASING.md" should contain:
      """

      ## jruby
      - [ ] `rvm use jruby@released`
      - [ ] `rm Gemfile.lock`
      - [ ] `bundle install`
      - [ ] `rake release`

      ## ruby-2.1
      - [ ] `rvm use ruby-2.1@released`
      - [ ] `rm Gemfile.lock`
      - [ ] `bundle install`
      - [ ] `rake release`
      ```

      ### Downstream dependencies
      """

  Scenario: Overridden ruby versions
    When I successfully run `metasploit-version install --force --no-bundle-install --ruby-versions maglev`
    Then the file "RELEASING.md" should contain:
      """

      ## maglev
      - [ ] `rvm use maglev@released`
      - [ ] `rm Gemfile.lock`
      - [ ] `bundle install`
      - [ ] `rake release`
      ```

      ### Downstream dependencies
      """
