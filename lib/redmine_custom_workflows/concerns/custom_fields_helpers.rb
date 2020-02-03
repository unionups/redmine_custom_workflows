module RedmineCustomWorkflows
  module Concerns
    module CustomFieldsHelpers
      extend ActiveSupport::Concern

      included do
          def new_custom_field 
            CustomField.new_subclass_instance get_custom_field_class_name
          end

          def create_custom_field *args
            cf = new_custom_field
            args[0][:field_format] = "string" if args[0][:field_format].blank?
            cf.attributes = args[0]
            cf.save
            cf
          end

          def find_custom_field_by *args
            CustomField.find_by(*args)
          end


          def find_or_create_custom_field_by *args
            find_custom_field_by(*args) || create_custom_field(*args)
          end

          def find_or_new_custom_field_by *args
            cf = find_custom_field_by(*args)
            unless cf
              cf = new_custom_field
              args[0][:field_format] = "string" if args[0][:field_format].blank?
              cf.attributes = args[0]
            end
            cf
          end

          private 
            def get_custom_field_class_name
              (self.class.name + "CustomField")
            end
      end
    end
  end
end