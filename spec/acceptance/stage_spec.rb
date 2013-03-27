require 'spec_helper'

describe 'borg app:stage task' do
  include_context 'acceptance'

  let(:stage_test_config) {
    <<-RUBY
stage :app, :prd do
  task :display_stage do
    puts "The stage is set to: \#{stage}"
  end
end
    RUBY
  }

  before do
    assert_execute('borgify')
  end

  context 'app with stages: prd, and a task `display_stage` which prints `stage`' do
    before do
      environment.create_file('cap/applications/app.rb', stage_test_config)
    end

    it 'the task prints `prd`' do
      result = execute('borg', 'app:prd', 'display_stage')
      puts result.stderr
      expect(result.stdout).to match(/The stage is set to: prd/)
    end
  end

end
