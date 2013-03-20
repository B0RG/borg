require 'spec_helper'
require 'borg/configuration/applications'

describe Borg::Configuration::Applications do
  it "should be included into Capistrano::Configuration" do
    Capistrano::Configuration.ancestors.should include Borg::Configuration::Applications
  end

  context "when a new Capistrano::Configuration is initialized" do
    subject { Capistrano::Configuration.new }
    it "should initialize the applications hash" do
      expect(subject.applications).to eq({})
    end
  end

  context "when an applications is defined" do
    before do
      @config = Capistrano::Configuration.new
      @config.load do
        application "app1" do
          test_notice "You have called app1"
        end
      end
    end
    subject { @config }

    it "should symobolize the name" do
      expect(subject.applications[:app1].name).to eq :app1
    end

    it "should create a namespace app1 with task default and a description" do
      expect(subject.namespaces[:app1]).to be_true
      expect(subject.namespaces[:app1].tasks[:default]).to be_true
      expect(subject.namespaces[:app1].tasks[:default].desc).to be_true
    end

    it "should add it to applications hash and have a block" do
      expect(subject.applications[:app1].class).to eq Borg::Configuration::Applications::Application
      expect(subject.applications[:app1].execution_blocks.count).to eq 1
    end
  end
end

describe Borg::Configuration::Applications::Application do
  it "should be initialize all variables" do
    app1 = Borg::Configuration::Applications::Application.new(:app1, double("namespace app1"))
    expect(app1.stages).to eq({})
    expect(app1.name).to eq(:app1)
    expect(app1.execution_blocks).to eq([])
  end

  context "an applications with 2 blocks" do
    before do
      @app1 = Borg::Configuration::Applications::Application.new(:app1, double("namespace app1"))
      @app1.execution_blocks << -> {
        raise "block 1 called"
      }
      @app1.execution_blocks << -> {
        raise "block 2 called"
      }
    end
    context "when #load_into is called" do
      it "should all blocks into the provided config" do
        config  = double("test config")
        config.should_receive(:load).twice
        @app1.load_into config
      end
    end
  end
end
