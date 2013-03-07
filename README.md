# Borg
This is a project inspired by Caphub. It expands on the concept and makes it into a framework for multi application
deployment.

# Setup
## Deployer Package

`borgify` Sets up the following structure

```
my-deployer-package
├── cap
|   ├── applications
|   |   ├── application1.rb
│   |   └── application2.rb
|   ├── initilizers
|   |   ├── initilizer1.rb
│   |   └── initilizer2.rb
|   └── recipies
|       ├── recipie1.rb
│       └── recipie2.rb
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

require 'borg'
```

## Services Package
`borgify plugin` Sets up the following structure

```
my-service-package
├── cap
|   ├── initilizers
|   |   ├── initilizer1.rb
│   |   └── initilizer2.rb
|   └── recipies
|       ├── recipie1.rb
│       └── recipie2.rb
├── my-service-package.gemspec
├── Gemfile
└── Gemfile.lock
```

### Guidelines
* While working on this there was a realization that the if you write a "on :exit" event then make sure it is executable
even if it is called when ctrl-c is hit.
