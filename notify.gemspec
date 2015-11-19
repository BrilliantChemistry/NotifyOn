$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "notify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "notify"
  s.version     = Notify::VERSION
  s.authors     = ["SideDolla"]
  s.email       = ["service@sidedolla.com"]
  s.homepage    = "http://sidedolla.com"
  s.summary     = "SideDolla notification plugin for models"
  s.description = "Allows simple declarative based notifications"
  s.license     = "Private"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"

  s.add_development_dependency "sqlite3"
end
