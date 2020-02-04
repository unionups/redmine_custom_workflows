module RedmineCustomWorkflows
  module Patches
    module CustomFieldValuePatch
      extend ActiveSupport::Concern
      included do 
        def on_change_refresh?
          custom_field.on_change_refresh?
        end
      end
    end
    module CustomFieldPatch
      extend ActiveSupport::Concern
      included do 
        def on_change_refresh?
          on_change_refresh.present?
        end
      end
    end
    module CustomFieldHelpersPatch
      def custom_field_tag(prefix, custom_value)
        if ["bool", "list", "attachment", "date"].include?( custom_value.custom_field.field_format) && custom_value.on_change_refresh?
          css = "#{custom_value.custom_field.field_format}_cf"
          data = nil
          if custom_value.custom_field.full_text_formatting?
            css += ' wiki-edit'
            data = {
              :auto_complete => true,
              :issues_url => auto_complete_issues_path(:project_id => custom_value.customized.project, :q => '')
            } if custom_value.customized && custom_value.customized.project
          end
          custom_value.custom_field.format.edit_tag(
            self,
            custom_field_tag_id(prefix, custom_value.custom_field),
            custom_field_tag_name(prefix, custom_value.custom_field),
            custom_value,
            :class => css,
            :data => data,
            onChange: "$('form.edit_user').attr('action', '#{user_refresh_path(custom_value.customized)}').submit()")
          
        else
          super
        end
      end
    end
  end
end

RedmineExtensions::PatchManager.register_model_patch 'CustomFieldValue',
  'RedmineCustomWorkflows::Patches::CustomFieldValuePatch'

RedmineExtensions::PatchManager.register_model_patch 'CustomField',
  'RedmineCustomWorkflows::Patches::CustomFieldPatch'


CustomFieldsHelper.send :prepend, RedmineCustomWorkflows::Patches::CustomFieldHelpersPatch
