module RedmineCustomWorkflows
  module Concerns
    module CustomFieldsHelpers
      extend ActiveSupport::Concern

      included do
          def new_custom_field 
          CustomField.new_subclass_instance get_custom_field_class_name
          end

          def create_custom_field *args
            cf = CustomField.new_subclass_instance get_custom_field_class_name
            cf.field_format = "string"
            cf.assign_attributes *args
            cf.save()
          end

          def find_custom_field_by *args
            CustomField.find_by *args
          end

          def find_or_create_custom_field_by *args
            cf = find_custom_field_by *args
            unless cf.present?
              cf = create_custom_field *args
            end  
            cf
          end

          private 
            def get_custom_field_class_name
              self.class.name << "CustomField"
            end
      end
    end
  end
end