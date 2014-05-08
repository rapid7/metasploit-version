require 'spec_helper'

describe Metasploit::Version::Full do
  subject(:base_module) do
    Module.new.tap { |mod|
      mod.extend described_class
      mod::MAJOR = major
      mod::MINOR = minor
      mod::PATCH = patch
    }
  end

  #
  # lets
  #

  let(:major) {
    1
  }

  let(:minor) {
    2
  }

  let(:patch) {
    3
  }

  context 'full' do
    subject(:full) do
      base_module.full
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
        base_module::PRERELEASE = prerelease
      end

      it 'is <MAJOR>.<MINOR>.<PATCH>-<PRERELEASE>' do
        expect(full).to eq("#{major}.#{minor}.#{patch}-#{prerelease}")
      end
    end

    context 'without PRERELEASE defined' do
      it 'is <MAJOR>.<MINOR>.<PATCH>' do
        expect(full).to eq("#{major}.#{minor}.#{patch}")
      end
    end
  end
end