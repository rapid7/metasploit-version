Feature: metasploit-version install should add CONTRIBUTING.md that handle pre-1.0.0 and post-1.0.0 versioning

  `metasploit-version install` should have different directions for updating the semantic version when it is
  < 1.0.0 and >= 1.0.0.

  Background:
    Given I successfully run `bundle gem contributed`
    And I cd to "contributed"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem contributed"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |

  Scenario: < 1.0.0
    When I successfully run `metasploit-version install --force --major 0 --minor 1 --patch 2 --no-bundle-install`
    Then the file "CONTRIBUTING.md" should contain:
      """
      ### Compatible changes
      
      If your changes are compatible with the previous branch's API, then increment [`PATCH`](lib/contributed/version.rb).
      
      ### Incompatible changes
      
      If your changes are incompatible with the previous branch's API you can either (1) decide to remain pre-1.0.0 or (2)
      advance to 1.0.0.
      
      1. To remain pre-1..0.0, then increment [`MINOR`](lib/contributed/version.rb) and reset [`PATCH`](lib/contributed/version.rb) to `0`.
      2. To advance to 1.0.0, increment [`MAJOR`](lib/contributed/version.rb) and reset [`MINOR`](lib/contributed/version.rb and [`PATCH`](lib/contributed/version.rb) to `0`.
      """

  Scenario: 1.0.0
    When I successfully run `metasploit-version install --force --major 1 --minor 0 --patch 0 --no-bundle-install`
    Then the file "CONTRIBUTING.md" should contain:
      """
      ### Bug fixes
      
      If your changes involve bug fixes, but don't affect the public API, then increment [`PATCH`](lib/contributed/version.rb).
      
      ### Compatible API changes
      
      If your changes involves widening of the API, such as adding new option parameters or adding new methods, then increment
      [`MINOR`](lib/contributed/version.rb) and reset [`PATCH`](lib/contributed/version.rb) to `0`.
      
      ### Incompatible API changes
      
      If your changes involve shrinking the API, such as dropping positional arguments from methods, removing methods or
      making arguments stricter, then increment [`MAJOR`](lib/contributed/version.rb) and reset [`MINOR`](lib/contributed/version.rb and
      [`PATCH`](lib/contributed/version.rb) to `0`.
      """

  Scenario: Version independent
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "CONTRIBUTING.md" should contain:
      """
      # Contributing

      ## Forking

      [Fork this repository](https://github.com/rapid7/contributed/fork)

      ## Branching

      Branch names follow the format `TYPE/ISSUE/SUMMARY`.  You can create it with `git checkout -b TYPE/ISSUE/SUMMARY`.

      ### `TYPE`

      `TYPE` can be `bug`, `chore`, or `feature`.

      ### `ISSUE`

      `ISSUE` is either a [Github issue](https://github.com/rapid7/contributed/issues) or an issue from some other
      issue tracking software.

      ### `SUMMARY`

      `SUMMARY` is is short summary of the purpose of the branch composed of lower case words separated by '-' so that it is a valid `PRERELEASE` for the Gem version.

      ## Changes

      ### `PRERELEASE`

      1. Update `PRERELEASE` to match the `SUMMARY` in the branch name.  If you branched from `master`, and [version.rb](lib/contributed/version.rb) does not have `PRERELEASE` defined, then adding the following lines after `PATCH`:
      ```
      # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version number.
      PRERELEASE = '<SUMMARY>'
      ```
      2. `rake spec`
      3.  Verify the specs pass, which indicates that `PRERELEASE` was updated correctly.
      4. Commit the change `git commit -a`

      ### Your changes

      Make your changes or however many commits you like, committing each with `git commit`.

      ### Pre-Pull Request Testing

      1. Run specs one last time before opening the Pull Request: `rake spec`
      2. Verify there was no failures.

      ### Push

      Push your branch to your fork on gitub: `git push TYPE/ISSUE/SUMMARY`

      ### Pull Request

      * [Create new Pull Request](https://github.com/rapid7/contributed/compare/)
      * Add a Verification Steps to the description comment

      ```
      # Verification Steps

      - [ ] `bundle install`

      ## `rake spec`
      - [ ] `rake spec`
      - [ ] VERIFY no failures
      ```

      You should also include at least one scenario to manually check the changes outside of specs.

      * Add a Post-merge Steps comment

      The 'Post-merge Steps' are a reminder to the reviewer of the Pull Request of how to update the [`PRERELEASE`](lib/contributed/version.rb) so that [version_spec.rb](spec/lib/contributed/version.rb_spec.rb) passes on the target branch after the merge.

      DESTINATION is the name of the destination branch into which the merge is being made.  SOURCE_SUMMARY is the SUMMARY from TYPE/ISSUE/SUMMARY branch name for the SOURCE branch that is being made.

      When merging to `master`:

      ```
      # Post-merge Steps

      Perform these steps prior to pushing to master or the build will be broke on master.

      ## Version
      - [ ] Edit `lib/contributed/version.rb`
      - [ ] Remove `PRERELEASE` and its comment as `PRERELEASE` is not defined on master.

      ## Gem build
      - [ ] gem build *.gemspec
      - [ ] VERIFY the gem has no '.pre' version suffix.

      ## RSpec
      - [ ] `rake spec`
      - [ ] VERIFY version examples pass without failures

      ## Commit & Push
      - [ ] `git commit -a`
      - [ ] `git push origin master`
      ```

      When merging to DESTINATION other than `master`:

      ```
      # Post-merge Steps

      Perform these steps prior to pushing to DESTINATION or the build will be broke on DESTINATION.

      ## Version
      - [ ] Edit `lib/contributed/version.rb`
      - [ ] Change `PRERELEASE` from `SOURCE_SUMMARY` to `DESTINATION_SUMMARY` to match the branch (DESTINATION) summary (DESTINATION_SUMMARY)

      ## Gem build
      - [ ] gem build contributed.gemspec
      - [ ] VERIFY the prerelease suffix has change on the gem.

      ## RSpec
      - [ ] `rake spec`
      - [ ] VERIFY version examples pass without failures

      ## Commit & Push
      - [ ] `git commit -a`
      - [ ] `git push origin DESTINATION`
      ```

      * Add a 'Release Steps' comment

      The 'Release Steps' are a reminder to the reviewer of the Pull Request of how to release the gem.

      ```
      # Release

      Complete these steps on DESTINATION

      ## `VERSION`

      """
    And the file "CONTRIBUTING.md" should contain:
      """

      ## jruby
      - [ ] `rvm use jruby@contributed`
      - [ ] `rm Gemfile.lock`
      - [ ] `bundle install`
      - [ ] `rake release`

      ## ruby-2.1
      - [ ] `rvm use ruby-2.1@contributed`
      - [ ] `rm Gemfile.lock`
      - [ ] `bundle install`
      - [ ] `rake release`
      ```

      ### Downstream dependencies

      There are currently no known downstream dependencies
      """
