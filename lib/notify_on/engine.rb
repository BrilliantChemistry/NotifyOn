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
      # Create an instance of each model so that we can hit :notify_on where it
      # is defined. This triggers the dynamic associations defined when
      # :notify_on is called.
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.each do |model|
        next if model.abstract_class?
        next unless ActiveRecord::Base.connection
          .data_source_exists?(model.table_name)
        model.new
      end
    end

  end
end
