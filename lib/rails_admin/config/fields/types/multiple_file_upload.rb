module RailsAdmin
  module Config
    module Fields
      module Types
        class MultipleFileUpload < RailsAdmin::Config::Fields::Base
          RailsAdmin::Config::Fields::Types.register(self)

          class AbstractAttachment
            include RailsAdmin::Config::Proxyable
            include RailsAdmin::Config::Configurable

            attr_reader :value

            def initialize(value)
              @value = value
            end

            register_instance_option :thumb_method do
              nil
            end

            register_instance_option :delete_key do
              nil
            end

            register_instance_option :export_value do
              resource_url.to_s
            end

            register_instance_option :pretty_value do
              if value.presence
                v = bindings[:view]
                url = resource_url
                if image
                  thumb_url = resource_url(thumb_method)
                  image_html = v.image_tag(thumb_url, class: 'img-thumbnail')
                  url != thumb_url ? v.link_to(image_html, url, target: '_blank') : image_html
                else
                  v.link_to(value, url, target: '_blank')
                end
              end
            end

            register_instance_option :image? do
              (url = resource_url.to_s) && url.split('.').last =~ /jpg|jpeg|png|gif|svg/i
            end

            def resource_url
              raise('not implemented')
            end
          end

          def initialize(*args)
            super
            @attachment_configurations = []
          end

          register_instance_option :attachment_class do
            AbstractAttachment
          end

          register_instance_option :partial do
            :form_multiple_file_upload
          end

          register_instance_option :cache_method do
            nil
          end

          register_instance_option :delete_method do
            nil
          end

          register_instance_option :allowed_methods do
            [method_name, cache_method, delete_method].compact
          end

          register_instance_option :html_attributes do
            {
              required: required? && !value.present?,
            }
          end

          def attachment(&block)
            @attachment_configurations << block
          end

          def attachments
            Array(value).map do |attached|
              attachment = attachment_class.new(attached).with(bindings)
              @attachment_configurations.each do |config|
                attachment.instance_eval(&config)
              end
              attachment
            end
          end

          # virtual class
          def virtual?
            true
          end
        end
      end
    end
  end
end
