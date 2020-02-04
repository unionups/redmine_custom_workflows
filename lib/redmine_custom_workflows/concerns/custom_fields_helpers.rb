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
            cf.assign_attributes args[0]
            cf.save
            cf
          end

          def find_custom_field_by *args
            CustomField.find_by(*args)
          end

          def find_custom_field *args
            CustomField.find(*args)
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

          def hide_field_by *args
            cfv = self.custom_field_values
            cfv.each do |value| 
              cfv.delete(value) if value.custom_field.attributes >= args[0].with_indifferent_access
            end
          end

          def field_value id
            cf = CustomField.find(id)
            cf.field_format == "bool" ? (self.custom_field_value(id) == "1") : self.custom_field_value(id)
          end


          private 
            def get_custom_field_class_name
              (self.class.name + "CustomField")
            end


      end
    end
  end
end

# hide_field(id) и поле скрылость при открытии формы
# insert_field(:cf_id, :type, :select_values, :action_after_select)