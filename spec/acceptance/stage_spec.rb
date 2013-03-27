require 'spec_helper'

describe 'borg app:stage task' do
  include_context 'acceptance'

  let(:app_config) { <<-RUBY.gsub(/^ {4}/, '')
    stage :app, :prd do
      task :display_stage do
        puts "The stage is set to: \#{stage}"
      end
    end
    stage :app, :stg do
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
      environment.create_file('cap/applications/app.rb', app_config)
    end

    it 'the task prints `prd` for app:prd, and `stg` for app:stg' do
      result = execute('borg', 'app:prd', 'display_stage')
      expect(result.stdout).to match(/The stage is set to: prd/)
      result = execute('borg', 'app:stg', 'display_stage')
      expect(result.stdout).to match(/The stage is set to: stg/)
    end
  end

end
