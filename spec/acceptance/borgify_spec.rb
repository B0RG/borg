require 'acceptance_spec_helper'

describe "borgify (in /bin/borgify)" do
  include_context "acceptance"

  before(:all) do
    assert_execute("borgify")
    @workdir = environment.workdir_path
  end

  it "creates a Gemfile that sources rubygems.org and contains borg-rb" do
    gemfile = @workdir.join("Gemfile")
    expect(gemfile.exist?).to be_true
    expect(gemfile.read).to match(/^source "https:\/\/rubygems.org"$/)
    expect(gemfile.read).to match(/borg-rb/)
  end

  it "creates a Capfile" do
    capfile = @workdir.join("Capfile")
    expect(capfile.exist?).to be_true
  end

  it "creates a lib directory" do
    capfile = @workdir.join("Capfile")
    expect(capfile.exist?).to be_true
  end

  it "create a cap directory with the following subdirectories: applications, initializers, recipes" do
    cap_dir = @workdir.join("cap")
    expect(cap_dir.exist?).to be_true
    expect(cap_dir.join("applications")).to be_true
    expect(cap_dir.join("initializers")).to be_true
    expect(cap_dir.join("recipes")).to be_true
  end
end

describe "borgify plugin" do
  include_context "acceptance"

  before(:all) do
    assert_execute("borgify", "plugin")
    @workdir = environment.workdir_path
  end

  it "creates a gemspec" do
    directory_name = File.basename(@workdir = environment.workdir_path)
    gemspec = @workdir = environment.workdir_path.join("#{directory_name}.gemspec")
    expect(gemspec.exist?).to be_true
  end
end