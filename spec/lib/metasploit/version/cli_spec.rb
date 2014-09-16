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

      it 'calls #ensure_development_dependency' do
        expect(cli).to receive(:ensure_development_dependency)

        install
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
end