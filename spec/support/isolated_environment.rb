require "fileutils"
require "pathname"
require "childprocess"

module Support
  # This class creates a temporary directory to act as the working directory
  #
  # Modified from: https://github.com/mitchellh/vagrant/blob/master/spec/support/isolated_environment.rb
  class IsolatedEnvironment
    ROOT_DIR = Pathname.new(File.expand_path("../../", __FILE__))

    attr_reader :workdir, :workdir_path

    def initialize
      # Create a temporary directory for our work
      @workdir = TempDir.new("borg")
      @workdir_path = Pathname.new(@workdir.path)
      # puts "Initialize isolated environment: #{@workdir_path.to_s}"
    end

    # Copies a skeleton into this isolated environment. This is useful
    # for testing environments that require a complex setup.
    #
    # @param [String] name Name of the skeleton in the root directory.
    def skeleton!(name)
      # Copy all the files into the home directory
      source = Dir.glob(ROOT_DIR.join(name).join("*").to_s)
      FileUtils.cp_r(source, @workdir.to_s)
    end

    # Executes a command in the context of this isolated environment.
    # Any command executed will therefore see our temporary directory
    # as the home directory.
    def execute(command, *argN)
      # Determine the options
      options = argN.last.is_a?(Hash) ? argN.pop : {}
      options = {
          workdir: @workdir_path,
          notify: [:stdin, :stderr, :stdout]
      }.merge(options)

      # Add the options to be passed on
      argN << options

      # Execute, logging out the stdout/stderr as we get it
      # puts("Executing: #{[command].concat(argN).inspect}")
      Support::Subprocess.execute(command, *argN) do |type, data|
        yield type, data if block_given?
      end
    end

    # Closes the environment and cleans it up
    def close
      # puts "Removing isolated environment: #{@workdir.path}"
      FileUtils.rm_rf(@workdir.path)
    end

    def file_write(filename, content)
      File.open @workdir_path.join(filename), "w" do |file|
        file.write(content)
      end
    end
  end
end
