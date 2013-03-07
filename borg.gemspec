$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "borg"
  s.version     = "0.0.1"
  s.authors     = ["Identified"]
  s.email       = ["phil@identified.com", "tejas@identified.com"]
  s.homepage    = "http://www.identified.com"
  s.summary     = "Add this later."
  s.description = "Add this later."

  s.files = Dir["{capistrano,service,lib}/**/*"] + ["Capfile", "README.md"]
  s.test_files = Dir["test/**/*"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency "capistrano"
  s.add_dependency "capistrano_colors"
  s.add_dependency "capistrano-multiconfig"
  s.add_dependency "colored"
  s.add_dependency 'term-ansicolor'
end
