require 'spec_helper'

describe 'borg app:stage task' do
  include_context 'acceptance'

  before do
    assert_execute('borgify')
  end

  context "app with no stages" do
    before do
      environment.file_write('cap/applications/app.rb', basic_app_config)
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
      environment.file_write('cap/applications/app.rb', app_config_with_stages)
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

end

def basic_app_config
  <<-RUBY
application :app do
  task :some_task do
  end
end
  RUBY
end

def app_config_with_stages
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
end
