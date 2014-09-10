require 'spec_helper'

describe Metasploit::Version::Branch do
  context 'CONSTANTS' do
    context 'JENKINS_PREFIX_REGEXP' do
      subject(:jenkins_prefix_regexp) {
        described_class::JENKINS_PREFIX_REGEXP
      }

      it "matches 'ref/remotes/' by itself" do
        expect(jenkins_prefix_regexp).to match('ref/remotes/')
      end

      it "matches 'ref/remotes/' prefix" do
        expect(jenkins_prefix_regexp).to match('ref/remotes/remote-name')
      end

      it 'matches nothing' do
        expect(jenkins_prefix_regexp).to match('')
      end
    end

    context 'PRERELEASE_REGEXP' do
      subject(:prerelease_regexp) {
        described_class::PRERELEASE_REGEXP
      }

      it 'matches a single segment' do
        expected_prerelease = 'singlesegment'
        match = prerelease_regexp.match(expected_prerelease)

        expect(match).not_to be_nil
        expect(match[:prerelease]).to eq(expected_prerelease)
      end

      it "matches segments separated by '-'" do
        expected_prerelease = 'first-second'
        match = prerelease_regexp.match(expected_prerelease)

        expect(match).not_to be_nil
        expect(match[:prerelease]).to eq(expected_prerelease)
      end

      it "matches segmented separated by '.'" do
        expected_prerelease = 'first.second'
        match = prerelease_regexp.match(expected_prerelease)

        expect(match).not_to be_nil
        expect(match[:prerelease]).to eq(expected_prerelease)
      end

      it "matches segmented separated by a mix of '.' and '-'" do
        expected_prerelease = 'first.second-third'
        match = prerelease_regexp.match(expected_prerelease)

        expect(match).not_to be_nil
        expect(match[:prerelease]).to eq(expected_prerelease)
      end
    end

    context 'PRERELEASE_SEGMENT_REGEXP' do
      subject(:prerelease_segment_regexp) {
        described_class::PRERELEASE_SEGMENT_REGEXP
      }

      it 'does not match an empty string' do
        expect(prerelease_segment_regexp).not_to match('')
      end

      it 'matches 0-9, a-z, and A-Z' do
        ranges = [
            '0'..'9',
            'a'..'z',
            'A'..'Z'
        ]
        string = ranges.map(&:to_a).map(&:join).join

        expect(prerelease_segment_regexp).to match(string)
      end
    end

    context 'STAGING_REGEXP' do
      subject(:staging_regexp) {
        described_class::STAGING_REGEXP
      }

      it 'matches staging branch' do
        expect(staging_regexp).to match('staging/long-running')
      end

      it 'does not match bug branch' do
        expect(staging_regexp).not_to match('bug/MSP-1234/nasty')
      end

      it 'does not match chore branch' do
        expect(staging_regexp).not_to match('chore/MSP-1234/repeating')
      end

      it 'does not match feature branch' do
        expect(staging_regexp).not_to match('feature/MSP-1234/new-feature')
      end

      it 'does not match pre-release tag' do
        expect(staging_regexp).not_to match('v1.2.3.pre.release')
      end

      it 'does not match release tag' do
        expect(staging_regexp).not_to match('v1.2.3')
      end
    end

    context 'STORY_REGEXP' do
      subject(:story_regexp) {
        described_class::STORY_REGEXP
      }

      it 'does not match staging branch' do
        expect(story_regexp).not_to match('staging/long-running')
      end

      context 'type' do
        context 'bug' do
          let(:type) {
            'bug'
          }

          context 'with story' do
            it 'matches' do
              expect(story_regexp).to match("#{type}/MSP-1234/nasty")
            end
          end

          context 'without story' do
            it 'does not match' do
              expect(story_regexp).not_to match("#{type}/nasty")
            end
          end
        end

        context 'chore' do
          let(:type) {
            'chore'
          }

          context 'with story' do
            it 'matches' do
              expect(story_regexp).to match("#{type}/MSP-1234/repeating")
            end
          end

          context 'without story' do
            it 'does not match' do
              expect(story_regexp).not_to match("#{type}/repeating")
            end
          end
        end

        context 'feature' do
          let(:type) {
            'feature'
          }

          context 'with story' do
            it 'matches' do
              expect(story_regexp).to match("#{type}/MSP-1234/cool")
            end
          end

          context 'without story' do
            it 'does not match' do
              expect(story_regexp).not_to match("#{type}/cool")
            end
          end
        end
      end

      it 'does not match pre-release tag' do
        expect(story_regexp).not_to match('v1.2.3.pre.release')
      end

      it 'does not match release tag' do
        expect(story_regexp).not_to match('v1.2.3')
      end
    end

    context 'VERSION_PRERELEASE_SEGMENT_SEPARATOR_REGEXP' do
      subject(:version_prerelease_segment_separator_regexp) {
        described_class::VERSION_PRERELEASE_SEGMENT_SEPARATOR_REGEXP
      }

      it { is_expected.to match('.pre.') }

      it "escapes '.' around 'pre'" do
        expect(version_prerelease_segment_separator_regexp).not_to match('aprea')
      end
    end

    context 'VERSION_REGEXP' do
      subject(:version_regexp) {
        described_class::VERSION_REGEXP
      }

      it "does not match tag without 'v' prefix" do
        expect(version_regexp).not_to match('1.2.3')
      end

      it 'matches release tag' do
        expect(version_regexp).to match('v1.2.3')
      end

      it 'matches prerelease tag' do
        expect(version_regexp).to match('v1.2.3.pre.release')
      end

      it 'does not match staging branch' do
        expect(version_regexp).not_to match('staging/long-running')
      end

      it 'does not match bug branch' do
        expect(version_regexp).not_to match('bug/MSP-1234/nasty')
      end

      it 'does not match chore branch' do
        expect(version_regexp).not_to match('chore/MSP-1234/recurring')
      end

      it 'does not match feature branch' do
        expect(version_regexp).not_to match('feature/MSP-1234/cool')
      end
    end
  end

  context 'current' do
    subject(:current) {
      described_class.current
    }

    around(:each) do |example|
      env_before = ENV.to_hash

      begin
        example.run
      ensure
        ENV.replace(env_before)
      end
    end

    context 'with TRAVIS_BRANCH' do
      before(:each) do
        ENV['TRAVIS_BRANCH'] = travis_branch
      end

      context 'that is empty' do
        let(:travis_branch) {
          ''
        }

        it 'parses git abbreviated ref' do
          expect(current).to eq(`git rev-parse --abbrev-ref HEAD`.strip)
        end
      end

      context 'that is not empty' do
        let(:travis_branch) {
          'feature/MSP-1234/travis-ci'
        }

        it 'is TRAVIS_BRANCH' do
          expect(current).to eq(travis_branch)
        end
      end
    end

    context 'without TRAVIS_BRANCH' do
      before(:each) do
        ENV.delete('TRAVIS_BRANCH')
      end

      it 'parses git abbreviated ref' do
        expect(current).to eq(`git rev-parse --abbrev-ref HEAD`.strip)
      end
    end
  end

  context 'parse' do
    subject(:parse) {
      described_class.parse(branch)
    }

    context 'with HEAD' do
      let(:branch) {
        'HEAD'
      }

      it { is_expected.to eq('HEAD') }
    end

    context 'with master' do
      let(:branch) {
        'master'
      }

      it { is_expected.to eq('master') }
    end

    context 'with staging branch' do
      let(:branch) {
        "#{expected_type}/#{expected_prerelease}"
      }

      let(:expected_prerelease) {
        'long-running'
      }

      let(:expected_type) {
        'staging'
      }

      it { is_expected.to be_a(Hash) }

      context '[:prerelease]' do
        subject(:prerelease) {
          parse[:prerelease]
        }

        it "is name after 'staging/'" do
          expect(prerelease).to eq(expected_prerelease)
        end
      end

      context '[:type]' do
        subject(:type) {
          parse[:type]
        }

        it { is_expected.to eq(expected_type) }
      end
    end

    context 'with story branch' do
      context 'for a bug' do
        let(:expected_prerelease) {
          'nasty'
        }

        let(:expected_type) {
          'bug'
        }

        context 'with story' do
          let(:expected_story) {
            'MSP-1234'
          }

          let(:branch) {
            "#{expected_type}/#{expected_story}/#{expected_prerelease}"
          }

          it { should be_a Hash }

          context '[:prerelease]' do
            subject(:prerelease) {
              parse[:prerelease]
            }

            it "is name after last '/'" do
              expect(prerelease).to eq(expected_prerelease)
            end
          end

          context '[:story]' do
            subject(:story) {
              parse[:story]
            }

            it 'is middle name' do
              expect(story).to eq(expected_story)
            end
          end

          context '[:type]' do
            subject(:type) {
              parse[:type]
            }

            it { is_expected.to eq(expected_type) }
          end
        end

        context 'without story' do
          let(:branch) {
            "#{expected_type}/#{expected_prerelease}"
          }

          it { is_expected.to be_nil }
        end
      end

      context 'for a chore' do
        let(:expected_prerelease) {
          'recurring'
        }

        let(:expected_type) {
          'chore'
        }

        context 'with story' do
          let(:expected_story) {
            'MSP-1234'
          }

          let(:branch) {
            "#{expected_type}/#{expected_story}/#{expected_prerelease}"
          }

          it { should be_a Hash }

          context '[:prerelease]' do
            subject(:prerelease) {
              parse[:prerelease]
            }

            it "is name after last '/'" do
              expect(prerelease).to eq(expected_prerelease)
            end
          end

          context '[:story]' do
            subject(:story) {
              parse[:story]
            }

            it 'is middle name' do
              expect(story).to eq(expected_story)
            end
          end

          context '[:type]' do
            subject(:type) {
              parse[:type]
            }

            it { is_expected.to eq(expected_type) }
          end
        end

        context 'without story' do
          let(:branch) {
            "#{expected_type}/#{expected_prerelease}"
          }

          it { is_expected.to be_nil }
        end
      end

            context 'for a bug' do
        let(:expected_prerelease) {
          'cool-new'
        }

        let(:expected_type) {
          'feature'
        }

        context 'with story' do
          let(:expected_story) {
            'MSP-1234'
          }

          let(:branch) {
            "#{expected_type}/#{expected_story}/#{expected_prerelease}"
          }

          it { should be_a Hash }

          context '[:prerelease]' do
            subject(:prerelease) {
              parse[:prerelease]
            }

            it "is name after last '/'" do
              expect(prerelease).to eq(expected_prerelease)
            end
          end

          context '[:story]' do
            subject(:story) {
              parse[:story]
            }

            it 'is middle name' do
              expect(story).to eq(expected_story)
            end
          end

          context '[:type]' do
            subject(:type) {
              parse[:type]
            }

            it { is_expected.to eq(expected_type) }
          end
        end

        context 'without story' do
          let(:branch) {
            "#{expected_type}/#{expected_prerelease}"
          }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'with version tag' do
      let(:expected_major) {
        10
      }

      let(:expected_minor) {
        20
      }

      let(:expected_patch) {
        30
      }

      context 'for pre-release' do
        let(:branch) {
          "v#{expected_major}.#{expected_minor}.#{expected_patch}.pre.early.pre.release"
        }

        it { is_expected.to be_a Hash }

        context '[:major]' do
          subject(:major) {
            parse[:major]
          }

          it { is_expected.to be_an Integer }

          it 'is first number in dotted version' do
            expect(major).to eq(expected_major)
          end
        end

        context '[:minor]' do
          subject(:minor) {
            parse[:minor]
          }

          it { is_expected.to be_an Integer }

          it 'is second number in dotted version' do
            expect(minor).to eq(expected_minor)
          end
        end

        context '[:patch]' do
          subject(:patch) {
            parse[:patch]
          }

          it { is_expected.to be_an Integer }

          it 'is third number in dotted version' do
            expect(patch).to eq(expected_patch)
          end
        end

        context '[:prerelease]' do
          subject(:prerelease) {
            parse[:prerelease]
          }

          it "converts '.pre.' separators from prerelease back to '-'" do
            expect(prerelease).to eq('early-release')
          end
        end
      end

      context 'for release' do
        let(:branch) {
          "v#{expected_major}.#{expected_minor}.#{expected_patch}"
        }

        it { is_expected.to be_a Hash }

        context '[:major]' do
          subject(:major) {
            parse[:major]
          }

          it { is_expected.to be_an Integer }

          it 'is first number in dotted version' do
            expect(major).to eq(expected_major)
          end
        end

        context '[:minor]' do
          subject(:minor) {
            parse[:minor]
          }

          it { is_expected.to be_an Integer }

          it 'is second number in dotted version' do
            expect(minor).to eq(expected_minor)
          end
        end

        context '[:patch]' do
          subject(:patch) {
            parse[:patch]
          }

          it { is_expected.to be_an Integer }

          it 'is third number in dotted version' do
            expect(patch).to eq(expected_patch)
          end
        end

        context '[:prerelease]' do
          subject(:prerelease) {
            parse[:prerelease]
          }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'with malformed bug branch' do
      let(:branch) {
        'bug/without-story'
      }

      it { is_expected.to be_nil }
    end

    context 'with malformed chore branch' do
      let(:branch) {
        'chore/without-story'
      }

      it { is_expected.to be_nil }
    end

    context 'with malformed feature branch' do
      let(:branch) {
        'feature/without-story'
      }

      it { is_expected.to be_nil }
    end

    context 'with malformed version tag' do
      let(:branch) {
        '1.2.3.pre.without.pre.v'
      }

      it { is_expected.to be_nil }
    end
  end

  context 'prerelease' do
    subject(:prerelease) {
      described_class.prerelease(gem_version_prerelease)
    }

    context 'with nil' do
      let(:gem_version_prerelease) {
        nil
      }

      it { is_expected.to be_nil }
    end

    context 'without nil' do
      context "with '.pre.'" do
        let(:gem_version_prerelease) {
          'second.pre.early.pre.release'
        }

        it "replaces '.pre.' with '-'" do
          expect(prerelease).to eq('second-early-release')
        end
      end

      context "without '.pre.'" do
        let(:gem_version_prerelease) {
          'prerelease'
        }

        it 'is unchanged' do
          expect(prerelease).to eq(gem_version_prerelease)
        end
      end
    end
  end
end