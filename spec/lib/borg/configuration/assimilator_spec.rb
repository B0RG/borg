require 'spec_helper'
require 'borg/configuration/assimilator'

describe Borg::Configuration::Assimilator do
  it "should be included into Capistrano::Configuration" do
    Capistrano::Configuration.new.should respond_to :assimilate
  end

  context "when #assimilate('borg-rb') is called" do
    subject { Capistrano::Configuration.new }
    it "should add to the to_assimilate list" do
      lambda {subject.assimilate('borg-rb')}.should change {subject.instance_eval("@to_assimilate")}.from(nil).to({'borg-rb' => Gem::Specification.find_by_name('borg-rb').gem_dir})
    end
  end

  context "when #assimilate! is called" do
    before do
      @config = Capistrano::Configuration.new
      @config.assimilate('borg-rb')
    end

    subject { @config }
    it "should loads all the initializers" do
      Dir["cap/initializers/**/*.rb"].each do |file|
        subject.should_receive(:load).with(File.expand_path(file))
      end
      subject.assimilate!
    end

    it "should add the cap directory to teh load path" do
      Dir.stub("[]").and_return([])
      lambda { subject.assimilate! }.should change(subject.load_paths, :count).by 1
    end
  end
end
