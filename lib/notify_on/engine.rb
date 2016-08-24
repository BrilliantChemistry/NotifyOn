module NotifyOn
  class Engine < ::Rails::Engine

    isolate_namespace NotifyOn

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.after_initialize do
      NotifyOn::BulkConfig.load
    end

  end
end
