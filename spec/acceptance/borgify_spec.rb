require 'spec_helper'

describe "borgify" do
  include_context "acceptance"

  before do
    assert_execute("borgify")
    @workdir = environment.workdir_path
  end

  it "creates the right files and directories" do
    # Gemfile
    gemfile = @workdir.join("Gemfile")
    expect(gemfile.file?).to be_true
    gemfile_contents = gemfile.read
    expect(gemfile_contents).to match(/^source "https:\/\/rubygems.org"$/)
    expect(gemfile_contents).to match(/borg-rb/)

    # Capfile
    capfile = @workdir.join("Capfile")
    expect(capfile.file?).to be_true

    # lib directory
    capfile = @workdir.join("lib")
    expect(capfile.directory?).to be_true

    # cap directory with the subdirectories: applications, initializers, recipes
    cap_dir = @workdir.join("cap")
    expect(cap_dir.directory?).to be_true
    expect(cap_dir.join("applications").directory?).to be_true
    expect(cap_dir.join("initializers").directory?).to be_true
    expect(cap_dir.join("recipes").directory?).to be_true
  end
end
