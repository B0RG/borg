require "fileutils"
require "pathname"
require "childprocess"

module Support
  # This class creates a temporary directory to act as the working directory for our tests
  # Modified from: https://github.com/mitchellh/vagrant/blob/master/spec/support/isolated_environment.rb
  class IsolatedEnvironment
    ROOT_DIR = Pathname.new(File.expand_path("../../", __FILE__))

    attr_reader :workdir, :workdir_path

    def initialize
      @workdir = TempDir.new("borg")
      @workdir_path = Pathname.new(@workdir.path)
    end

    # Executes a command in the context of this isolated environment.
    # Any command executed will therefore see our working directory
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

      # Execute
      Support::Subprocess.execute(command, *argN) do |type, data|
        yield type, data if block_given?
      end
    end

    # Remove everything created in the environment
    def close
      FileUtils.rm_rf(@workdir_path)
    end

    # Creates a new file in the isolated environment
    #
    # @param [String] filename Name of destination file's path relative to the isolated environment's root
    # @param [String] content The stuff
    def create_file(filename, content)
      Dir.chdir(@workdir_path) do
        FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
        File.open(filename, "w") { |file| file.write(content) }
      end
    end

    # Copies a directory into this isolated environment.
    #
    # @param [String] src_dir Name of the source directory's path relative to the root directory.
    # @param [String] dest_dir Name of path relative to the isolated environment's root
    def copy_dir(src_dir, dest_dir = "/")
      # Copy all the files into the home directory
      source = Dir.glob(ROOT_DIR.join(name).join("*").to_s)
      FileUtils.cp_r(source, @workdir_path.to_s)
    end

    # Copies a file into this isolated environment.
    #
    # @param [String] src_file Name of the source file's path relative to the root directory.
    # @param [String] dest_file Name of destination file's path relative to the isolated environment's root
    def copy_file(src_file, dest_file)
      Dir.chdir(@workdir_path) do
        FileUtils.mkdir_p(File.dirname(dest_file)) unless File.directory?(File.dirname(dest_file))
        FileUtils.cp(ROOT_DIR.join(src_file), dest_file)
      end
    end
  end
end
