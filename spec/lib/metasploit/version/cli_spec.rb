require 'spec_helper'

describe Metasploit::Version::CLI do
  subject(:cli) {
    described_class.new
  }

  context 'CONSTANTS' do
    context 'GEM_NAME' do
      subject(:gem_name) {
        described_class::GEM_NAME
      }

      it { is_expected.to eq('metasploit-version') }
    end

    context 'DEVELOPMENT_DEPENDENCY_LINE' do
      subject(:development_dependency_line) {
        described_class::DEVELOPMENT_DEPENDENCY_LINE
      }

      if Metasploit::Version::Version::MAJOR > 0
        it { is_expected.to eq("  spec.add_development_dependency 'metasploit-version', '~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}'\n")}
      else
        it { is_expected.to eq("  spec.add_development_dependency 'metasploit-version', '~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}.#{Metasploit::Version::Version::PATCH}'\n")}
      end
    end

    context 'DEVELOPMENT_DEPENDENCY_REGEXP' do
      subject(:development_dependency_regexp) {
        described_class::DEVELOPMENT_DEPENDENCY_REGEXP
      }

      it { is_expected.to match(%q{spec.add_development_dependency 'metasploit-version'})}
      it { is_expected.to match(%q{spec.add_development_dependency "metasploit-version"})}
    end
  end

  context 'commands' do
    context '#install' do
      subject(:install) {
        cli.install
      }

      before(:each) do
        allow(cli).to receive(:ensure_development_dependency)
        allow(cli).to receive(:template)
        allow(cli).to receive(:install_bundle)
        allow(cli).to receive(:setup_rspec)
      end

      it 'calls #ensure_development_dependency' do
        expect(cli).to receive(:ensure_development_dependency)

        install
      end

      it 'generates version.rb from a template' do
        expect(cli).to receive(:template).with('lib/versioned/version.rb.tt', 'lib/metasploit/version/version.rb')

        install
      end

      it 'installs bundle' do
        expect(cli).to receive(:install_bundle)

        install
      end

      it 'generates CONTRIBUTING.md from a template' do
        expect(cli).to receive(:template).with('CONTRIBUTING.md.tt', 'CONTRIBUTING.md')

        install
      end

      it 'generates RELEASING.md from a template' do
        expect(cli).to receive(:template).with('RELEASING.md.tt', 'RELEASING.md')

        install
      end

      it 'setups up rspec' do
        expect(cli).to receive(:setup_rspec)

        install
      end
    end
  end

  context '#capitalize' do
    subject(:capitalize) {
      cli.send(:capitalize, word)
    }

    context 'with single character' do
      let(:word) {
        'a'
      }

      it 'capitalizes letter' do
        expect(capitalize).to eq('A')
      end
    end

    context 'with multiple characters' do
      context 'with multiple capitals' do
        let(:word) {
          'hTML'
        }

        it 'does not change capitalization of other characters' do
          expect(capitalize).to eq('HTML')
        end
      end

      context 'with underscored' do
        let(:word) {
          'underscored_words'
        }

        it 'uppercases first letter of first word' do
          expect(capitalize).to eq('Underscored_words')
        end
      end

      context 'with hyphenated' do
        let(:word) {
          'hyphenated-words'
        }

        it 'uppercases first letter of the first word' do
          expect(capitalize).to eq('Hyphenated-words')
        end
      end
    end
  end

  context '#ensure_development_dependency' do
    subject(:ensure_development_dependency) {
      cli.send(:ensure_development_dependency)
    }

    #
    # lets
    #

    let(:gemspec) {
      Tempfile.new(['gem', '.gemspec']).tap { |tempfile|
        tempfile.write(
<<EOS
Gem::Specification.new do |spec|
#{line}
end
EOS
        )
        tempfile.flush
      }
    }

    #
    # Callbacks
    #

    before(:each) do
      expect(cli).to receive(:gemspec_path).and_return(gemspec.path)
    end

    context "with `spec.add_development_dependency 'metasploit-version'`" do
      let(:line) {
        "  spec.add_development_dependency 'metasploit-version'"
      }

      it 'adds semantic version requirement' do
        ensure_development_dependency

        gemspec_after = File.read(gemspec.path)

        expect(gemspec_after.scan('metasploit-version').length).to eq(1)
        expect(gemspec_after).to match(/spec\.add_development_dependency 'metasploit-version', '~> #{Metasploit::Version::Version::MAJOR}\.#{Metasploit::Version::Version::MINOR}\.#{Metasploit::Version::Version::PATCH}'/)
      end
    end

    context "with `spec.add_development_dependency 'metasploit-version', <requirements>`" do
      let(:line) {
        "  spec.add_development_dependency 'metasploit-version', '~> 0.0.0'"
      }

      it 'changes semantic version requirement' do
        ensure_development_dependency

        gemspec_after = File.read(gemspec.path)

        expect(gemspec_after.scan('metasploit-version').length).to eq(1)
        expect(gemspec_after).to match(/spec\.add_development_dependency 'metasploit-version', '~> #{Metasploit::Version::Version::MAJOR}\.#{Metasploit::Version::Version::MINOR}\.#{Metasploit::Version::Version::PATCH}'/)
      end
    end

    context "without `spec.add_development_dependency 'metasploit-version'`" do
      let(:line) {
        ''
      }

      it 'adds metaspoit-version as a development dependency' do
        ensure_development_dependency

        gemspec_after = File.read(gemspec.path)

        expect(gemspec_after.scan('metasploit-version').length).to eq(1)
        expect(gemspec_after).to match(/spec\.add_development_dependency 'metasploit-version', '~> #{Metasploit::Version::Version::MAJOR}\.#{Metasploit::Version::Version::MINOR}\.#{Metasploit::Version::Version::PATCH}'/)
      end
    end
  end

  context '#gemspec_path' do
    subject(:gemspec_path) {
      cli.send(:gemspec_path)
    }

    #
    # lets
    #

    let(:name) {
      'newgem'
    }

    #
    # Callbacks
    #

    around(:each) do |example|
      Dir.mktmpdir do |directory|
        Dir.chdir(directory) do
          Dir.mkdir(name)

          Dir.chdir(name) do
            example.run
          end
        end
      end
    end

    context 'with 0 gemspecs' do
      it 'print that no gemspecs were found' do
        expect(cli.shell).to receive(:say).with('No gemspec found')

        expect {
          gemspec_path
        }.to raise_error(SystemExit)
      end

      it 'exits with non-zero status' do
        expect {
          gemspec_path
        }.to raise_error(SystemExit) { |error|
          expect(error.status).not_to eq(0)
        }
      end
    end

    context 'with 1 gemspec' do
      #
      # lets
      #

      let(:expected_path) {
        "#{name}.gemspec"
      }

      #
      # Callbacks
      #

      before(:each) do
        File.write(expected_path, '')
      end

      it 'is relative path to gemspec' do
        expect(gemspec_path).to eq(expected_path)
      end
    end
  end

  context '#name' do
    subject(:name) do
      cli.send(:name)
    end

    #
    # lets
    #

    let(:expected_name) {
      'expected-name'
    }

    #
    # Callbacks
    #

    around(:each) do |example|
      Dir.mktmpdir do |directory|
        Dir.chdir(directory) do
          Dir.mkdir(expected_name)

          Dir.chdir(expected_name) {
            example.run
          }
        end
      end
    end

    it 'is the basename of the pwd' do
      expect(name).to eq(expected_name)
    end
  end

  context 'namespace_name' do
    subject(:namespace_name) {
      cli.send(:namespace_name)
    }

    #
    # lets
    #

    let(:namespaces) {
      %w{First Second Third}
    }

    #
    # Callbacks
    #

    before(:each) do
      expect(cli).to receive(:namespaces).and_return([namespaces])
    end

    it 'joins namespaces together with Module separator' do
      expect(namespace_name).to eq('First::Second::Third')
    end
  end

  context '#namespaces' do
    subject(:namespaces) {
      cli.send(:namespaces)
    }

    #
    # Callbacks
    #

    before(:each) do
      expect(cli).to receive(:name).and_return(name)
    end

    context 'with single word' do
      let(:name) {
        'yard'
      }

      it 'is array with capitalized word' do
        expect(namespaces).to eq(%w{Yard})
      end
    end

    context 'with multiple words' do
      context 'separated by dashes' do
        let(:name) {
          'metasploit-version'
        }

        it 'is array with each word capitalized' do
          expect(namespaces).to eq(%w{Metasploit Version})
        end
      end

      context 'separated by underscores' do
        let(:name) {
          'metasploit_data_models'
        }

        it 'is array with single word camelized' do
          expect(namespaces).to eq(%w{MetasploitDataModels})
        end
      end

      context 'separated by dashes and underscores' do
        let(:name) {
          'debugger-ruby_core_source'
        }

        it 'is array with underscored words camelized and a separate word for each pair of hyphenated separated words' do
          expect(namespaces).to eq(%w{Debugger RubyCoreSource})
        end
      end
    end
  end

  context '#namespaced_path' do
    subject(:namespaced_path) {
      cli.send(:namespaced_path)
    }

    #
    # lets
    #

    let(:name) {
      'debugger-ruby_core_source'
    }

    #
    # Callbacks
    #

    before(:each) do
      expect(cli).to receive(:name).and_return(name)
    end

    it "converts '-' to '/" do
      expect(namespaced_path).not_to include('-')
      expect(namespaced_path).to include('_')
      expect(namespaced_path).to eq('debugger/ruby_core_source')
    end
  end
end