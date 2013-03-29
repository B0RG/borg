require 'spec_helper'
require 'borg/configuration/applications'

describe Borg::Configuration::Applications do
  before :all do
    class MockConfiguration < Capistrano::Configuration
      include Borg::Configuration::Applications
    end
  end

  after :all do
    Object.send(:remove_const, :MockConfiguration)
  end

  let(:config) { MockConfiguration.new }

  it 'initializes the applications hash' do
    expect(config.applications.class).to eq Hash
  end

  context 'when applications are defined' do
    before do
      config.load do
        application 'app1' do
          test_notice 'You have called app1'

        end
      end
    end

    it_behaves_like 'an application configuration'

    it 'creates an execution block for the application' do
      expect(config.applications[:app1].execution_blocks.count).to eq 1
    end
  end

end

describe Borg::Configuration::Applications::Application do
  it 'initializes: stage, name, and execution_blocks' do
    app1 = Borg::Configuration::Applications::Application.new(:app1, double('namespace app1'))
    expect(app1.stages).to eq({})
    expect(app1.name).to eq(:app1)
    expect(app1.execution_blocks).to eq([])
  end

  context 'an applications with 2 blocks' do
    before do
      @app1 = Borg::Configuration::Applications::Application.new(:app1, double('namespace app1'))
      @app1.execution_blocks << -> {
        raise 'block 1 called'
      }
      @app1.execution_blocks << -> {
        raise 'block 2 called'
      }
    end

    context 'when #load_into is called' do
      it 'loads all blocks into the provided config' do
        config  = double('test config')
        config.should_receive(:load).twice
        @app1.load_into config
      end
    end
  end
end
