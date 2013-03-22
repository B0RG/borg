require 'acceptance_spec_helper'

describe "borgify" do
  include_context "acceptance"

  before do
    assert_execute("borgify")
    @workdir = environment.workdir_path
  end

  it "creates the right files and directories" do
    # Gemfile
    gemfile = @workdir.join("Gemfile")
    expect(gemfile.exist?).to be_true
    expect(gemfile.read).to match(/^source "https:\/\/rubygems.org"$/)
    expect(gemfile.read).to match(/borg-rb/)

    # Capfile
    capfile = @workdir.join("Capfile")
    expect(capfile.exist?).to be_true

    # lib directory
    capfile = @workdir.join("lib")
    expect(capfile.exist?).to be_true

    # cap directory with the subdirectories: applications, initializers, recipes
    cap_dir = @workdir.join("cap")
    expect(cap_dir.exist?).to be_true
    expect(cap_dir.join("applications")).to be_true
    expect(cap_dir.join("initializers")).to be_true
    expect(cap_dir.join("recipes")).to be_true
  end
end

describe "borgify plugin" do
  include_context "acceptance"

  before do
    assert_execute("borgify", "plugin")
    @workdir = environment.workdir_path
  end

  it "creates the right files and directories" do
    # the gemspec
    directory_name = File.basename(@workdir = environment.workdir_path)
    gemspec = @workdir = environment.workdir_path.join("#{directory_name}.gemspec")
    expect(gemspec.exist?).to be_true
  end
end