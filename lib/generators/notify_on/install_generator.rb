module NotifyOn
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path("../../templates", __FILE__)

    def generate_migration
      attrs  = "recipient_id:integer recipient_type:string sender_id:integer "
      attrs += "sender_type:string unread:boolean trigger_id:integer "
      attrs += "trigger_type:string description:text link:string "
      attrs += "use_default_email:boolean"
      generate "migration create_notify_on_notifications #{attrs}"

      gsub_file Dir.glob('db/migrate/*.rb').last, /t\.boolean\ \:unread/,
                't.boolean :unread, :default => true'
      gsub_file Dir.glob('db/migrate/*.rb').last,
                /t\.boolean\ \:use_default_email/,
                't.boolean :use_default_email, :default => false'
      gsub_file Dir.glob('db/migrate/*.rb').last, /t\.string\ \:link/,
                "t.string :link\n      t.timestamps"
    end

    def copy_initializer
      template "notify_on.rb", "config/initializers/notify_on.rb"
    end

  end
end
