$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'notify_on/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'notify_on'
  s.version     = NotifyOn::VERSION
  s.authors     = ['Mike Wille', 'Sean C Davis']
  s.email       = ['service@brilliantchemistry.com']
  s.homepage    = 'https://github.com/BrilliantChemistry/NotifyOn'
  s.summary     = 'Declaritive Notifications for Rails apps.'
  s.description = 'Simple declarative based notifications for Ruby on Rails applications.'
  s.license     = 'MIT'
  s.test_files  = Dir['spec/**/*']

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'em-http-request'
  s.add_dependency 'hashie'
  s.add_dependency 'pusher'
  s.add_dependency 'rails', '>= 4.2'

  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  # s.add_development_dependency 'bootstrap', '~> 4.0.0.alpha3.1'
  s.add_development_dependency 'bootstrap-sass', '~> 3.3.6'
  s.add_development_dependency 'sass-rails', '>= 3.2'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'devise'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'jquery-rails'
  s.add_development_dependency 'mailcatcher'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'simple_form'
end
