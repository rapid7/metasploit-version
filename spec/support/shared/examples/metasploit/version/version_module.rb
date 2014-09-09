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
    example_options = {}

    if !pull_request.nil? && pull_request != 'false'
      example_options = {
          pending: "PRERELEASE can only be set appropriately for a merge by merging to the target branch and then " \
                   "updating PRERELEASE on the target branch before committing and/or pushing to github and travis-ci."
      }
    end

    context 'PRERELEASE' do
      subject(:prerelease) do
        described_class::PRERELEASE
      end

      branch = Metasploit::Version::Branch.current
      parsed_branch = Metasploit::Version::Branch.parse(branch)

      #
      # Methods
      #

      # use define_method to capture `parsed_branch`
      define_method(:expect_prerelease_to_be_defined) do
        expect(defined? described_class::PRERELEASE).not_to(
            be_nil,
            # lambda so error string is only calculated on failures
            ->() {
              "expected #{described_class}::PRERELEASE to be defined.\n" \
              "Add the following to #{described_class}:\n" \
              "\n" \
              "    # The prerelease version, scoped to the {PATCH} version number.\n" \
              "    PRERELEASE = #{parsed_branch[:prerelease]}"
            }
        )
      end

      # unknown format
      if parsed_branch.nil?
        # unknown format is still wrong, even on a pull request, so don't use `example_options`
        it 'has an abbreviated reference that can be parsed for prerelease' do
          fail "Do not know how to parse #{branch.inspect} for PRERELEASE"
        end
      # detached HEAD in git
      elsif parsed_branch == 'HEAD'
        it 'has an abbreviated reference that can be parsed for prerelease',
           pending: "Cannot determine branch name in detached HEAD state.  Set TRAVIS_BRANCH to supply branch name" do
          fail "Do not know how to parse #{branch.inspect} for PRERELEASE"
        end
      # master
      elsif parsed_branch == 'master'
        it 'is not defined', example_options do
          expect(defined? described_class::PRERELEASE).to(
              be_nil,
              "expected #{described_class}::PRERELEASE not to be defined on master"
          )
        end
      # non-master branches
      elsif parsed_branch.has_key? :type
        it "matches the #{parsed_branch[:type]} branch's name", example_options do
          expect_prerelease_to_be_defined
          expect(prerelease).to eq(parsed_branch[:prerelease])
        end
      # tags
      else
        # pre-release tag
        if parsed_branch[:prerelease]
          it 'matches the tag prerelease converted from a gem version to a VERSION', example_options do
            expect_prerelease_to_be_defined
            expect(prerelease).to eq(parsed_branch[:prerelease])
          end
        # master tag
        else
          it 'is not defined', example_options do
            expect(defined? described_class::PRERELEASE).to(
                be_nil,
                "expected #{described_class}::PRERELEASE not to be defined on master"
            )
          end
        end
      end
    end
  end

  context 'full' do
    subject(:full) {
      described_class.full
    }

    #
    # Methods
    #

    def expect_method_defined
      expect(defined? described_class.full).to(
          eq("method"),
          # lambda so expensive message calculation only happens on failure
          ->() {
            "expected #{described_class} to define self.full().\n" \
            "Add the following to #{described_class}\n" \
            "\n" \
            "    # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the\n" \
            "    # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.\n" \
            "    #\n" \
            "    # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch\n" \
            "    #   other than master.\n" \
            "    def self.full\n" \
            "      version = \"\#{MAJOR}.\#{MINOR}.\#{PATCH}\"\n" \
            "\n" \
            "      if defined? PRERELEASE\n" \
            "        version = \"\#{version}-\#{PRERELEASE}\"\n" \
            "      end\n" \
            "\n" \
            "      version\n" \
            "   end"
          }
      )
    end

    #
    # Callbacks
    #

    before(:each) do
      expect_method_defined
    end

    context 'with PRERELEASE defined' do
      #
      # lets
      #

      let(:prerelease) {
        'prerelease'
      }

      #
      # Callbacks
      #

      before(:each) do
        stub_const("#{described_class}::PRERELEASE", prerelease)
      end

      it 'is <MAJOR>.<MINOR>.<PATCH>-<PRERELEASE>' do
        expect(full).to eq("#{described_class::MAJOR}.#{described_class::MINOR}.#{described_class::PATCH}-#{prerelease}")
      end
    end

    context 'without PRERELEASE defined' do
      before(:each) do
        hide_const("#{described_class}::PRERELEASE")
      end

      it 'is <MAJOR>.<MINOR>.<PATCH>' do
        expect(full).to eq("#{described_class::MAJOR}.#{described_class::MINOR}.#{described_class::PATCH}")
      end
    end
  end

  context 'gem' do
    subject(:gem) {
      described_class.gem
    }

    before(:each) do
      expect(described_class).to receive(:full).and_return('1.2.3-multiword-prerelease')
    end

    it "replaces '-' with '.pre.' to be compatible with rubygems 1.8.6" do
      gem_method = described_class.method(:gem)
      method_arity = gem_method.arity

      expect(method_arity).to(
          eq(0),
          # lambda so expensive message calculation only happens on failure
          ->() {
            method_location = gem_method.source_location
            method_file = method_location[0]
            method_line = method_location[1]

            "expected #{described_class} to define self.gem(), but method defined by #{gem_method.owner} in " \
            "#{method_file} on line #{method_line} with arity #{method_arity}.\n" \
            "Add the following to #{described_class}:\n" \
            "\n" \
            "   # The full gem version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the\n" \
            "   # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.\n" \
            "   #\n" \
            "   # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}.{PRERELEASE}' on any branch\n" \
            "   #   other than master.\n" \
            "   def self.gem\n" \
            "     full.gsub('-', '.pre.')\n" \
            "   end"
          }
      )

      expect(gem).to eq('1.2.3.pre.multiword.pre.prerelease')
    end
  end
end