# Borg
This is a project inspired by Caphub. It expands on the concept and makes it into a framework for multi application
deployment.

[![Build Status](https://travis-ci.org/B0RG/borg.png?branch=master)](https://travis-ci.org/B0RG/borg)
[![Dependency Status](https://gemnasium.com/B0RG/borg.png)](https://gemnasium.com/B0RG/borg)
[![Code Climate](https://codeclimate.com/github/B0RG/borg.png)](https://codeclimate.com/github/B0RG/borg)

## Setup
### Deployer Package

`borgify` Sets up the following structure

```
my-deployer-package
├── cap
|   ├── applications
|   |   ├── application1.rb
│   |   └── application2.rb
|   ├── initilizers
|   |   ├── initializer1.rb
│   |   └── initializer2.rb
|   └── recipies
|       ├── recipe1.rb
│       └── recipe2.rb
├── Capfile
├── Gemfile
└── Gemfile.lock
```

### Default Capfile contents
```
# provides a performance report at the end of execution
# set :borg_performance_reports, true

# runs on :exit events when ctrl-c is hit
# set :borg_sigint_triggers_exit, true

load 'borg'
# load any other borg gems here.
# NOTE: require ends up causing the initializers to be called every time a config is loaded.

```

### Services Package
`borgify plugin` Sets up the following structure

```
my-service-package
├── cap
|   ├── initilizers
|   |   ├── initializer1.rb
│   |   └── initializer2.rb
|   └── recipies
|       ├── recipe1.rb
│       └── recipe2.rb
├── my-service-package.gemspec
├── Gemfile
└── Gemfile.lock
```

### Guidelines
* While working on this there was a realization that the if you write a "on :exit" event then make sure it is executable
even if it is called when ctrl-c is hit.

## Borg Application Config
Borg provides a application and stage config setup.
One can define applications with the format.
``` ruby
application :app_name do
  do things needed to setup the application environment.
end

stage :app_name, :stage_name do
  do things for specific stage for the applications.
end
```

By default borg looks for application confi files in cap/applications and loads all those files.
If multiple application and stage blocks with the same parameters are defined 
then all the blocks will be run for that application/stage.

The CLI enforces that all configs be specified at the start. Consider the command `borg app1:stage1 app2 deploy`
will result in config app1:stage1, all configs for app2 (1 config for each stage, if there is no stage it assumes the app is the only stage)
to be load and the deploy task be run against all of them.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
