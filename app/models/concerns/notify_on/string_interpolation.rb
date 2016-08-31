module NotifyOn
  module StringInterpolation
    extend ActiveSupport::Concern

    private

      def convert_string(input)
        (output = input.to_s).scan(/{[\w\_\.]+}/).each do |match|
          result = begin
            match.gsub(/[^\w\_\.]/, '').split('.').inject(trigger, :send)
          rescue
            match.gsub(/[^\w\_\.]/, '').split('.').inject(self, :send)
          end
          output = output.gsub(/#{match}/, result.to_s)
        end
        output.gsub(/\{:env}/, Rails.env.downcase)
              .gsub(/\{:recipient_id}/, recipient_id.to_s)
      end

      def convert_link(input)
        input = input.split(/\(|\)|,/).map(&:strip)
        if %w(_path _url).select { |r| input[0].end_with?(r) }.blank?
          return convert_string(input[0])
        end
        args = []
        input[1..-1].each do |arg|
          args << if %w(self :self).include?(arg)
            trigger
          else
            (arg[0] == ':') ? trigger.send(arg[1..-1]) : arg
          end
        end
        Rails.application.routes.url_helpers.send(input[0], *args)
      end

  end
end
