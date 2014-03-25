require "support/isolated_environment"

shared_context "acceptance" do
  # Setup the environment so that we have an isolated area to run our acceptance tests
  let!(:environment) { Support::IsolatedEnvironment.new }

  after do
    environment.close
  end

  # Executes the given command in the context of the isolated environment.
  #
  # @return [Object]
  def execute(*args, &block)
    environment.execute(*args, &block)
  end

  # This method is an assertion helper for asserting that a process
  # succeeds. It is a wrapper around `execute` that asserts that the
  # exit status was successful.
  def assert_execute(*args, &block)
    result = execute(*args, &block)
    expect(result).to succeed
    result
  end

end

