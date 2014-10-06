Feature: metasploit-version install should add RELEASING.md that handles pre-1.0.0 and post-1.0.0 versioning

  `metasploit-version install` should have different directions for update the semantic version when it is < 1.0.0 and
  >= 1.0.0

  Background:
    Given I successfully run `bundle gem released`
    And I cd to "released"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem released"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |

  Scenario: < 1.0.0
    When I successfully run `metasploit-version install --force --major 0 --minor 1 --patch 2 --no-bundle-install`
    Then the file "RELEASING.md" should contain:
      """
      ### Compatible changes

      If your changes are compatible with the previous branch's API, then increment [`PATCH`](lib/released/version.rb).

      ### Incompatible changes

      If your changes are incompatible with the previous branch's API you can either (1) decide to remain pre-1.0.0 or (2)
      advance to 1.0.0.

      1. To remain pre-1..0.0, then increment [`MINOR`](lib/released/version.rb) and reset [`PATCH`](lib/released/version.rb) to `0`.
      2. To advance to 1.0.0, increment [`MAJOR`](lib/released/version.rb) and reset [`MINOR`](lib/released/version.rb and [`PATCH`](lib/released/version.rb) to `0`.
      """

  Scenario: 1.0.0
    When I successfully run `metasploit-version install --force --major 1 --minor 0 --patch 0 --no-bundle-install`
    Then the file "RELEASING.md" should contain:
      """
      ### Bug fixes

      If your changes involve bug fixes, but don't affect the public API, then increment [`PATCH`](lib/released/version.rb).

      ### Compatible API changes

      If your changes involves widening of the API, such as adding new option parameters or adding new methods, then increment
      [`MINOR`](lib/released/version.rb) and reset [`PATCH`](lib/released/version.rb) to `0`.

      ### Incompatible API changes

      If your changes involve shrinking the API, such as dropping positional arguments from methods, removing methods or
      making arguments stricter, then increment [`MAJOR`](lib/released/version.rb) and reset [`MINOR`](lib/released/version.rb and
      [`PATCH`](lib/released/version.rb) to `0`.
      """

  Scenario: Version indepedent
    When I successfully run `metasploit-version install --force --major 0 --minor 1 --patch 2 --no-bundle-install`
    Then the file "RELEASING.md" should contain:
      """
      # Releasing

      These steps can be added to the Pull Request description's task list to remind the reviewer of how to release the
      gem.

      ```
      # Release

      Complete these steps on DESTINATION

      ## `VERSION`

      """
    And the file "RELEASING.md" should contain:
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

      There are currently no known downstream dependencies
      """
