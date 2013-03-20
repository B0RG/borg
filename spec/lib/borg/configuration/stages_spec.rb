require 'spec_helper'
require 'borg/configuration/applications'
require 'borg/configuration/stages'

describe Borg::Configuration::Stages do
  it "should be included into Capistrano::Configuration" do
    Capistrano::Configuration.ancestors.should include Borg::Configuration::Stages
  end

  context "when an applications is defined" do
    before do
      @config = Capistrano::Configuration.new
      @config.load do
        stage "app1", "stg1" do
          test_notice "You have called app1 stg1"
        end
      end
    end
    subject { @config }

    it "should create application since it does not exist" do
      expect(subject.applications[:app1]).to be_true
    end

    it "should symobolize the name" do
      expect(subject.applications[:app1].stages.keys.first).to eq :stg1
    end

    it "should create a namespace app1 with task stg1 and a description" do
      expect(subject.namespaces[:app1]).to be_true
      expect(subject.namespaces[:app1].tasks[:stg1]).to be_true
      expect(subject.namespaces[:app1].tasks[:stg1].desc).to be_true
    end

    it "should add it to applications hash and have a block" do
      expect(subject.applications[:app1].stages[:stg1].class).to eq Borg::Configuration::Stages::Stage
      expect(subject.applications[:app1].stages[:stg1].execution_blocks.count).to eq 1
    end
  end
end

describe Borg::Configuration::Stages::Stage do
  it "should be initialize all variables" do
    parent = double "app1"
    parent.stub(:name).and_return :app1
    stg1 = Borg::Configuration::Stages::Stage.new(:stg1, parent)
    expect(stg1.name).to eq("app1:stg1")
    expect(stg1.parent).to eq(parent)
    expect(stg1.execution_blocks).to eq([])
  end

  context "a stage with 2 blocks" do
    before do
      @stg1 = Borg::Configuration::Stages::Stage.new(:stg1, double("app1"))
      @stg1.execution_blocks << -> {
        raise "block 1 called"
      }
      @stg1.execution_blocks << -> {
        raise "block 2 called"
      }
    end
    context "when #load_into is called" do
      it "should all blocks into the provided config" do
        config  = double("test config")
        @stg1.parent.should_receive(:load_into).with(config)
        config.should_receive(:load).twice
        @stg1.load_into config
      end
    end
  end
end
