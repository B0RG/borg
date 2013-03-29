require 'spec_helper'
require 'borg/configuration/applications'
require 'borg/configuration/stages'

describe Borg::Configuration::Stages do
  before :all do
    class MockConfiguration < Capistrano::Configuration
      # TODO: Stages has a dependency on Applications module, is that bad?
      include Borg::Configuration::Applications
      include Borg::Configuration::Stages
    end
  end

  after :all do
    Object.send(:remove_const, :MockConfiguration)
  end

  let(:config) { MockConfiguration.new }

  context 'when an application with a stage is defined' do
    before do
      config.load do
        stage 'app1', 'stg1' do
          test_notice 'You have called app1 stg1'
        end
      end
    end

    it_behaves_like 'an application configuration'

    it 'creates and stores a new Stage object with a name and execution block' do
      expect(config.applications[:app1].stages[:stg1].class).to eq Borg::Configuration::Stages::Stage
      expect(config.applications[:app1].stages[:stg1].name).to eq 'app1:stg1'
      expect(config.applications[:app1].stages[:stg1].execution_blocks.count).to eq 1
    end
  end
end

describe Borg::Configuration::Stages::Stage do
  it 'initializes: name, parent and execution_blocks' do
    parent = double('app1')
    parent.stub(:name).and_return(:app1)
    stg1 = Borg::Configuration::Stages::Stage.new(:stg1, parent)
    expect(stg1.name).to eq('app1:stg1')
    expect(stg1.parent).to eq(parent)
    expect(stg1.execution_blocks).to eq([])
  end

  context 'a stage with 2 blocks' do
    before do
      @stg1 = Borg::Configuration::Stages::Stage.new(:stg1, double('app1'))
      @stg1.execution_blocks << -> {
        raise 'block 1 called'
      }
      @stg1.execution_blocks << -> {
        raise 'block 2 called'
      }
    end
    context 'when #load_into is called' do
      it 'should all blocks into the provided config' do
        config  = double('test config')
        @stg1.parent.should_receive(:load_into).with(config)
        config.should_receive(:load).twice
        @stg1.load_into(config)
      end
    end
  end
end
