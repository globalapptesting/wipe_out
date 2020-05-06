$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "wipe_out/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "wipe_out"
  s.version     = WipeOut::VERSION
  s.authors     = ["GAT"]
  s.email       = ["developers@globalapptesting.com"]
  s.homepage    = "http://not-yet-set"
  s.summary     = "wipe_out gem"
  s.description = "wipe_out gem"
  s.license     = "internal"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "attr_extras"
  s.add_dependency "rails"
  s.add_dependency "zeitwerk"

  s.add_development_dependency "combustion", "~> 1.3"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "pg"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
end
