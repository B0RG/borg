require 'spec_helper'

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
    expect(gemspec.file?).to be_true
  end
end
