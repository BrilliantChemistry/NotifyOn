module NotifyOn::MailerHelper

  def method_missing(method, *args, &block)
    m = method.to_s
    super unless m.ends_with?('_path') || m.ends_with?('_url')
    main_app.send(m, *args)
  end

end
