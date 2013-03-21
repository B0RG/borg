require 'spec_helper'
require 'borg/configuration/assimilator'

describe Borg::Configuration::Assimilator do
  it "should be included into Capistrano::Configuration" do
    Capistrano::Configuration.new.should respond_to :assimilate
  end

  context "when assimilate('borg') is called" do
    subject { Capistrano::Configuration.new }
    it "should loads all the initializers" do
      Dir["cap/initializers/**/*.rb"].each do |file|
        subject.should_receive(:load).with(File.expand_path(file))
      end
      subject.assimilate ('borg-rb')
    end

    it "should add the cap directory to teh load path" do
      Dir.stub("[]").and_return([])
      lambda { subject.assimilate ('borg-rb') }.should change(subject.load_paths, :count).by 1
    end
  end
end
