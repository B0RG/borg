require 'spec_helper'
require 'borg/cli/applications'

describe Borg::CLI::Applications do
  before :all do
    class MockCLI < Capistrano::CLI
      include Borg::CLI::Applications
    end
  end

  after :all do
    Object.send(:remove_const, :MockCLI)
  end

  def app_config
    <<-RUBY.gsub(/^ {4}/, '')
      end
      application :app1 do
        puts 'application = app1'
      end

      stage :app1, :prd do
        puts 'stage = prd'
      end

      stage :app1, :stg do
        puts 'stage = stg'
      end

      stage :app1, :alf do
        puts 'stage = alf'
      end
    RUBY
  end

  before :all do
    @env = Support::IsolatedEnvironment.new
    @env.create_file('cap/applications/app.rb', app_config)
    @app_config_path = @env.workdir_path.join('cap/applications/app.rb')
    @files = [@app_config_path]
  end

  after :all do
    @env.close
  end

  before do
    Dir.stub('[]').and_return(@files)
    @cli = MockCLI.new([])
    @config = double('config1')
  end

  describe '#load_applications' do
    before do
      @files.each { |f| @config.should_receive(:load).with(f) }
    end

    it 'loads files in ./cap/applications/**/*.rb' do
      @cli.send :load_applications, @config
    end

    context 'when already invoked in the past' do
      before do
        @cli.send :load_applications, @config
      end

      it 'does not load files in ./cap/applications/**/*.rb anymore' do
        @config2 = double('config2')
        @cli.send :load_applications, @config2
        @files.each { |f| @config2.should_not_receive(:load).with(f) }
      end
    end
  end

  describe '#separate_actions_and_applications' do
    before do
      @cli.instance_eval do
        @options = {}
        @options[:actions] = %w{app1 app2:stg1 app2:stg3 test test2}
      end
      @config.stub(:applications).
          and_return({app1: double('app1'), app2: double('app2')})
      @config.applications[:app1].stub(:stages).and_return({})
      @config.applications[:app2].stub(:stages).
          and_return({stg1: double('stg1'),stg2: double('stg2')})
    end
    it 'removes all applications from actions' do
      @cli.send :separate_actions_and_applications, @config
      expect(@cli.options[:actions]).to eq %w{app2:stg3 test test2}
      expect(@cli.options[:applications]).to eq [
                                                    @config.applications[:app1],
                                                    @config.applications[:app2].stages[:stg1]
                                                ]
    end

    it 'queues both stages if app2' do
      @cli.instance_eval do
        @options[:actions] = %w{app1 app2 test test2}
      end

      @cli.send :separate_actions_and_applications, @config

      expect(@cli.options[:actions]).to eq %w{test test2}
      expect(@cli.options[:applications]).to eq [
                                                    @config.applications[:app1],
                                                    @config.applications[:app2].stages[:stg1],
                                                    @config.applications[:app2].stages[:stg2]
                                                ]
    end

    it 'raises an exception when configs are not isolated to start of the actions list' do
      @cli.instance_eval do
        @options[:actions] << 'app2:stg2'
      end
      expect{
        @cli.send(:separate_actions_and_applications, @config)
      }.to raise_error(ArgumentError, 'Can not have non application configs between application configs')
    end

  end

  describe '#execute_requested_actions_with_applications' do
    before do
      @cli.instance_eval do
        @apps_loaded = true
        @options = {}
        @options[:actions] = %w{app1 app2:stg1 app2:stg3 test test2}
        @options[:applications] = []
      end
      @config.stub(:applications).and_return({})
      @cli.stub(:execute_requested_actions_without_applications)
    end

    it 'loads applications' do
      @cli.should_receive(:load_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    it 'separates actions and applications' do
      @cli.should_receive(:separate_actions_and_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    it 'calls #execute_requested_actions_without_applications when there is an empty applications list' do
      @cli.should_receive(:execute_requested_actions_without_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    context 'when applications exist' do
      before do
        apps = [double(:app1), double(:app2)]
        apps[0].stub(:name).and_return(:app1)
        apps[1].stub(:name).and_return(:app2)
        @cli.instance_eval do
          @options[:applications] = apps
        end
        @cli.stub(:puts)
      end

      after do
        Thread.current[:borg_application] = nil
      end

      it 'calls execute! for each application' do
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.should_receive(:execute!).with().twice
        @cli.execute_requested_actions_with_applications @config
      end

      it 'sets Thread.current[:borg_application]' do
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.stub(:execute!) do
          expect(@cli.options[:applications]).to include Thread.current[:borg_application]
        end
        @cli.execute_requested_actions_with_applications @config
      end

      it 'calls #execute_requested_actions_without_applications when Thread.current[:borg_application] is set' do
        Thread.current[:borg_application] = @cli.options[:applications][0]
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.should_receive(:execute_requested_actions_without_applications).with(@config)
        @cli.options[:applications][0].stub(:load_into)
        @cli.execute_requested_actions_with_applications @config
      end

      it 'loads the application config when Thread.current[:borg_application] is set' do
        Thread.current[:borg_application] = @cli.options[:applications][0]
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.stub(:execute_requested_actions_without_applications)
        @cli.options[:applications][0].should_receive(:load_into)
        @cli.execute_requested_actions_with_applications @config
      end
    end
  end
end
