require 'spec_helper'

describe 'borg app:stage task' do
  include_context 'acceptance'

  # TODO: probably want to have some factory that generates what we want in an app config to DRY this out
  let(:basic_app_config) {
    <<-RUBY
application :app do
  task :some_task do
  end
end
    RUBY
  }

  let(:app_config_with_stages) {
    <<-RUBY
application :app do
  task :common_task do
  end
end
stage :app, :prd do
  task :prd_task do
  end
end
stage :app, :stg do
  task :stg_task do
  end
end
    RUBY
  }

  let(:app_config_with_display_app_task) {
    <<-RUBY
application :app do
  task :display_app do
    puts "The application is set to: \#{application}"
  end
end
    RUBY
  }

  let(:app_config_with_stage_with_display_app_task) {
    <<-RUBY
stage :app, :prd do
  task :display_app do
    puts "The application is set to: \#{application}"
  end
end
    RUBY
  }

  before do
    assert_execute('borgify')
  end

  context "app with no stages" do
    before do
      environment.create_file('cap/applications/app.rb', basic_app_config)
    end

    it "allows us to run tasks for that app" do
      # a task defined for the app
      assert_execute('borg', 'app', 'some_task')

      # an undefined task
      expect(execute('borg', 'app', 'undefined_task')).to_not succeed

      # an undefined app
      expect(execute('borg', 'undefined_app', 'some_task')).to_not succeed
    end
  end

  context "app with stages: prd, stg" do
    before do
      environment.create_file('cap/applications/app.rb', app_config_with_stages)
    end

    it "allows us to set common/stage-specific tasks" do
      # commonly defined tasks
      assert_execute('borg', 'app:prd', 'common_task')
      assert_execute('borg', 'app:stg', 'common_task')

      # stage specific tasks in their respective stages
      assert_execute('borg', 'app:prd', 'prd_task')
      assert_execute('borg', 'app:stg', 'stg_task')

      # stage specific tasks in other stages
      expect(execute('borg', 'app:stg', 'prd_task')).to_not succeed
      expect(execute('borg', 'app:prd', 'stg_task')).to_not succeed
    end
  end

  context 'app with a task `display_app` which prints `application`' do
    before do
      environment.create_file('cap/applications/app.rb', app_config_with_display_app_task)
    end

    it 'the task prints `app`' do
      result = execute('borg', 'app', 'display_app')
      expect(result.stdout).to match(/The application is set to: app/)
    end
  end

  context 'app with stages: prd, and a task `display_app` which prints `application`' do
    before do
      environment.create_file('cap/applications/app.rb', app_config_with_stage_with_display_app_task)
    end

    it 'the task prints `app`' do
      result = execute('borg', 'app:prd', 'display_app')
      expect(result.stdout).to match(/The application is set to: app/)
    end
  end

end
