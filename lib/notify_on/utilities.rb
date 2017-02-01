module NotifyOn
  class Utilities

    def self.callback_method_name(action, options)
      opts = options.merge(:action => action)
      opts.each { |k, v| opts[k] = v.to_s.gsub(/\?/, '') }
      "notify_#{opts[:to]}_on_#{opts[:action]}" +
      ("_if_#{opts[:if]}" if opts[:if].present?).to_s +
      ("_unless_#{opts[:unless]}" if opts[:unless].present?).to_s
    end

  end
end
