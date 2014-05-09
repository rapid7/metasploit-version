shared_examples_for 'Metasploit::Version Version Module' do
  context 'CONSTANTS' do
    context 'MAJOR' do
      subject(:major) do
        described_class::MAJOR
      end

      it { should be_an Integer }
    end

    context 'MINOR' do
      subject(:minor) do
        described_class::MINOR
      end

      it { should be_a Integer }
    end

    context 'PATCH' do
      subject(:patch) do
        described_class::PATCH
      end

      it { should be_a Integer }
    end

    pull_request = ENV['TRAVIS_PULL_REQUEST']

    # a pull request cannot check PRERELEASE because it will be tested in the target branch, but the source itself
    # is from the source branch and so has the source branch PRERELEASE.
    #
    # PRERELEASE can only be set appropriately for a merge by merging to the target branch and then updating PRERELEASE
    # on the target branch before committing and/or pushing to github and travis-ci.
    if pull_request.nil? || pull_request == 'false'
      context 'PREPRELEASE' do
        subject(:prerelease) do
          described_class::PRERELEASE
        end

        branch = ENV['TRAVIS_BRANCH']

        # can't use blank? because activesupport isn't a dependency as blank? would be the only reason to use it.
        if branch.nil? || branch.empty?
          branch = `git rev-parse --abbrev-ref HEAD`.strip
        end

        # can't check PRERELEASE in  detached HEAD state (when you do `git checkout SHA`) because then the commit isn't
        # isn't associated with a branch anymore.
        unless branch == 'HEAD'
          if branch == 'master'
            it 'does not have a PRERELEASE' do
              expect(defined? described_class::PRERELEASE).to be_nil
            end
          else
            branch_regex = /\A(bug|feature|staging)\/(?<prerelease>.*)\z/
            match = branch.match(branch_regex)

            if match
              it 'matches the branch relative name' do
                expect(prerelease).to eq(match[:prerelease])
              end
            else
              it 'has a abbreviated reference that can be parsed for prerelease' do
                fail "Do not know how to parse #{branch.inspect} for PRERELEASE"
              end
            end
          end
        end
      end
    end
  end
end