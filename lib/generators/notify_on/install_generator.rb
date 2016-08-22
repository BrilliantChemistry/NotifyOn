module NotifyOn
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path("../../templates", __FILE__)

    def generate_migration
      attrs  = "recipient_id:integer recipient_type:string sender_id:integer "
      attrs += "sender_type:string unread:boolean trigger_id:integer "
      attrs += "trigger_type:string description_raw:text "
      attrs += "description_cached:text link_raw:string link_cached:string "
      attrs += "use_default_email:boolean options:text"
      generate "migration create_notify_on_notifications #{attrs}"

      gsub_file Dir.glob('db/migrate/*.rb').last, /t\.boolean\ \:unread/,
                't.boolean :unread, :default => true'
      gsub_file Dir.glob('db/migrate/*.rb').last,
                /t\.boolean\ \:use_default_email/,
                't.boolean :use_default_email, :default => false'
      gsub_file Dir.glob('db/migrate/*.rb').last, /t\.text\ \:options/,
                "t.text :options\n      t.timestamps"
    end

    def copy_initializer
      template "notify_on.rb", "config/initializers/notify_on.rb"
    end

  end
end
