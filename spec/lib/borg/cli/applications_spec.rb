require 'spec_helper'
require 'borg/cli/applications'

describe Borg::CLI::Applications do
  before :each do
    @config = double("config1")
    @files = %w{cap/applications/app1.rb cap/applications/app1/stg1.rb cap/applications/app1/stg2.rb}
    Dir.stub("[]").and_return(@files)
    @cli = Capistrano::CLI.new([])
  end

  context "#load_applications when called" do
    before do
      @files.each { |f| @config.should_receive(:load).with(f) }
    end

    it "should load all files in ./cap/applications/**/*.rb" do
      @cli.send :load_applications, @config
    end

    context "with a second call" do
      before do
        @cli.send :load_applications, @config
        @config2 = double("config2")
        @files.each { |f| @config2.should_not_receive(:load).with(f) }
      end

      it "should not load all files in ./cap/applications/**/*.rb for further calls" do
        @cli.send :load_applications, @config2
      end
    end
  end

  context "#separate_actions_and_applications when called" do
    before do
      @cli.instance_eval do
        @options = {}
        @options[:actions] = %w{app1 app2:stg1 app2:stg3 test test2}
      end
      @config.stub(:applications).and_return({
                                                 app1: double("app1"),
                                                 app2: double("app2")
                                             })
      @config.applications[:app1].stub(:stages).and_return({})
      @config.applications[:app2].stub(:stages).and_return({
                                                              stg1: double("stg1"),
                                                              stg2: double("stg2")
                                                          })
    end
    it "should remove all applications from actions" do
      @cli.send :separate_actions_and_applications, @config
      @cli.options[:actions].should == %w{app2:stg3 test test2}
      @cli.options[:applications].should == [
          @config.applications[:app1],
          @config.applications[:app2].stages[:stg1]
      ]
    end

    it "should queue both stages if app2" do
      @cli.instance_eval do
        @options[:actions] = %w{app1 app2 test test2}
      end

      @cli.send :separate_actions_and_applications, @config

      @cli.options[:actions].should == %w{test test2}
      @cli.options[:applications].should == [
          @config.applications[:app1],
          @config.applications[:app2].stages[:stg1],
          @config.applications[:app2].stages[:stg2]
      ]
    end

    it "should raise exception if configs are not isolated to start of the actions list" do
      @cli.instance_eval do
        @options[:actions] << "app2:stg2"
      end
      expect{ @cli.send(:separate_actions_and_applications, @config)}.to raise_error(ArgumentError, "Can not have non application configs between application configs")
    end

  end

  context "#execute_requested_actions_with_applications when called" do
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

    it "should load applications" do
      @cli.should_receive(:load_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    it "should separate actions and applications" do
      @cli.should_receive(:separate_actions_and_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    it "should call #execute_requested_actions_without_applications when there is an empty applications list" do
      @cli.should_receive(:execute_requested_actions_without_applications).with(@config)
      @cli.execute_requested_actions_with_applications @config
    end

    context "when applications exist" do
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

      it "should call call execute! for each application" do
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.should_receive(:execute!).with().twice
        @cli.execute_requested_actions_with_applications @config
      end

      it "should set Thread's borg_application" do
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.stub(:execute!) do
          @cli.options[:applications].should include Thread.current[:borg_application]
        end
        @cli.execute_requested_actions_with_applications @config
      end

      it "should call #execute_requested_actions_without_applications when Thread's borg_application is set" do
        Thread.current[:borg_application] = @cli.options[:applications][0]
        @cli.stub(:load_applications)
        @cli.stub(:separate_actions_and_applications)
        @cli.should_receive(:execute_requested_actions_without_applications).with(@config)
        @cli.options[:applications][0].stub(:load_into)
        @cli.execute_requested_actions_with_applications @config
      end

      it "should load the application's config when Thread's borg_application is set" do
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
