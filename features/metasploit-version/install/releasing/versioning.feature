Feature: metasploit-version install should add RELEASING.md that handles pre-1.0.0 and post-1.0.0 versioning

  `metasploit-version install` should have different directions for update the semantic version when it is < 1.0.0 and
  >= 1.0.0.  These instructions should be based on the contents of CHANGELOG.md.

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

      If the [CHANGELOG.md](CHANGELOG.md) contains only Enhancements, Bug Fixes, and/or Deprecations for the Next Release then
      increment [`PATCH`](lib/released/version.rb).

      ### Incompatible changes

      If the [CHANGELOG.md](CHANGELOG.md) contains any Incompatible Changes for the Next Release, then you can either (1)
      decide to remain pre-1.0.0 or (2) advance to 1.0.0.

      1. To remain pre-1..0.0, then increment [`MINOR`](lib/released/version.rb) and reset [`PATCH`](lib/released/version.rb) to `0`.
      2. To advance to 1.0.0, increment [`MAJOR`](lib/released/version.rb) and reset [`MINOR`](lib/released/version.rb and [`PATCH`](lib/released/version.rb) to `0`.

      """

  Scenario: 1.0.0
    When I successfully run `metasploit-version install --force --major 1 --minor 0 --patch 0 --no-bundle-install`
    Then the file "RELEASING.md" should contain:
      """
      ### Bug fixes

      If the [CHANGELOG.md](CHANGELOG.md) contains only Bug Fixes for the Next Release, then increment
      [`PATCH`](lib/released/version.rb).

      ### Compatible API changes

      If the [CHANGELOG.md](CHANGELOG.md) contains any Enhancements or Deprecations, then increment
      [`MINOR`](lib/released/version.rb) and reset [`PATCH`](lib/released/version.rb) to `0`.

      ### Incompatible API changes

      If the [CHANGELOG.md](CHANGELOG.md) contains any Incompatible Change, then increment [`MAJOR`](lib/released/version.rb) and
      reset [`MINOR`](lib/released/version.rb and [`PATCH`](lib/released/version.rb) to `0`.

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

      ## [CHANGELOG.md](CHANGELOG.md)

      ### Terminology

      * "Enhancements" are widdening the API, such as by adding new classes or methods.
      * "Bug Fixes" are fixes to the implementation that do not affect the public API.  If the public API is affected then
        the change should be listed as both a "Bug Fix" and either an "Enhancement" or "Incompatible Change" depending on how
        the bug was fixed.
      * "Deprecations" are changes to the implementation that cause deprecation warnings to be issued for APIs which will be
        removed in a future major release.  "Deprecations" are usually accompanied by an Enhancement that creates a new API
        that is meant to be used in favor of the deprecated API.
      * "Incompatbile Changes" are the removal of classes or methods or new required arguments or setup that shrink the API.
        It is best practice to make a "Deprecation" for the API prior to its removal.

      ### Task List

      - [ ] Generate the list of changes since the last release: `git log v<LAST_MAJOR>.<LAST_MINOR>.<LAST_PATCH>..HEAD`
      - [ ] For each commit in the release, find the corresponding PR by search for the commit on Github.
      - [ ] For each PR, determine whether it is an Enhancement, Bug Fix, Deprecation, and/or Incompatible Change.  A PR can
            be in more than one category, in which case it should be listed in each category it belongs, but with a category
            specific description of the change.
      - [ ] Add an item to each category's list in the following format: `[#<PR>](https://github.com/rapid7/released/pull/<PR>) <consumer summary> - [@<github_user>](https://github.com/<github_user>)`
            `consumer_summary` should be a summary of the Enhancement, Bug Fix, Deprecation, or Incompatible Change from a
            downstream consumer's of the library's perspective.  `github_user` should be Github handle of the author of the
            PR.
      - [ ] If you added any Deprecations or Incompatible Changes, then adding upgrading information to
            [UPGRADING.md](UPGRADING.md)

      ## `VERSION`

      The entries in the [CHANGELOG.md](CHANGELOG.md) can be used to help determine how the `VERSION` should be bumped.

      """
    And the file "RELEASING.md" should contain:
      """

      ## Setup [CHANGELOG.md](CHANGELOG.md) for next release

      - [ ] Change `Next Release` section name at the top of [CHANGELOG.md](CHANGELOG.md) to match the current `VERSION`.
      - [ ] Add a new `Next Release` section above the `VERSION`'s section you just renamed:
      <pre>
      # Next Release

      * Enhancements
      * Bug Fixes
      * Deprecations
      * Incompatible Changes
      </pre>

      ## Release to rubygems.org

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

      There are currently no known downstream dependenci
      """

