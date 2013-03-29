require 'spec_helper'
require 'borg/configuration/assimilator'

describe Borg::Configuration::Assimilator do
  before :all do
    class MockConfiguration < Capistrano::Configuration
      include Borg::Configuration::Assimilator
    end
  end

  after :all do
    Object.send(:remove_const, :MockConfiguration)
  end

  before do
    @config = MockConfiguration.new
  end
  describe '#assimilate' do
    it 'adds to the to_assimilate array' do
      expect {
        @config.assimilate('borg-rb')
      }.to change {
        @config.instance_eval('@to_assimilate')
      }.from(nil).to({'borg-rb' => Gem::Specification.find_by_name('borg-rb').gem_dir})
    end
  end

  describe '#assimilate!' do
    context 'given we already called assimilate with: `borg-rb`' do
      before do
        @config.assimilate('borg-rb')
      end

      it 'loads all the initializers' do
        Dir['cap/initializers/**/*.rb'].each do |file|
          @config.should_receive(:load).with(File.expand_path(file))
        end
        @config.assimilate!
      end

      it 'adds the cap directory to the load path' do
        Dir.stub('[]').and_return([])
        expect {
          @config.assimilate!
        }.to change(@config.load_paths, :count).by 1
      end
    end
  end
end
