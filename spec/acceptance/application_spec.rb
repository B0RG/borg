require 'spec_helper'

describe 'borg app:stage task' do
  include_context 'acceptance'

  let(:app_config) { <<-RUBY.gsub(/^ {4}/, '')
    application :app do
      task :app_task do
      end
      task :display_app do
        puts "The application is set to: \#{application}"
      end
    end
  RUBY
  }

  let(:app_config_with_stages) { app_config.concat <<-RUBY.gsub(/^ {6}/, '')
    stage :app, :prd do
      task :prd_task do
      end
    end
    stage :app, :stg do
      task :stg_task do
      end
    end
    stage :app, :alf
  RUBY
  }

  before do
    assert_execute('borgify')
  end

  context 'app with no stages' do
    before do
      environment.create_file('cap/applications/app.rb', app_config)
    end

    it 'allows us to execute tasks defined for the app' do
      # a task defined for the app
      assert_execute('borg', 'app', 'app_task')

      # an undefined task
      expect(execute('borg', 'app', 'undefined_task')).to_not succeed

      # an undefined app
      expect(execute('borg', 'undefined_app', 'some_task')).to_not succeed
    end

    it 'can read the `application` capistrano variable' do
      result = execute('borg', 'app', 'display_app')
      expect(result.stdout).to match(/The application is set to: app/)
    end
  end

  context 'app config with stages: prd, stg' do
    before do
      environment.create_file('cap/applications/app.rb', app_config_with_stages)
    end

    it 'allows us to execute common/stage-specific tasks' do
      # commonly defined tasks
      assert_execute('borg', 'app:prd', 'app_task')
      assert_execute('borg', 'app:stg', 'app_task')
      assert_execute('borg', 'app:alf', 'app_task')

      # stage specific tasks in their respective stages
      assert_execute('borg', 'app:prd', 'prd_task')
      assert_execute('borg', 'app:stg', 'stg_task')

      # stage specific tasks in other stages
      expect(execute('borg', 'app:stg', 'prd_task')).to_not succeed
      expect(execute('borg', 'app:prd', 'stg_task')).to_not succeed
    end

    it 'can read the `application` capistrano variable' do
      expect(execute('borg', 'app:prd', 'display_app').stdout).to match(/The application is set to: app/)
      expect(execute('borg', 'app:stg', 'display_app').stdout).to match(/The application is set to: app/)
    end
  end

end
