module RedmineCustomWorkflows
  module Patches
    module DocumentPatch

      def self.included(base)
        base.class_eval do
          before_save :before_save_custom_workflows
          after_save :after_save_custom_workflows
          before_destroy :before_destroy_custom_workflows
          after_destroy :after_destroy_custom_workflows
        end
      end

    
      include RedmineCustomWorkflows::Concerns::CustomFieldsHelpers


      private

        def before_save_custom_workflows
          @document = self
          @saved_attributes = attributes.dup
          CustomWorkflow.run_shared_code(self)
          CustomWorkflow.run_custom_workflows(:document, self, :before_save)
          throw :abort if errors.any?
          errors.empty? && (@saved_attributes == attributes || valid?)
        ensure
          @saved_attributes = nil
        end

        def after_save_custom_workflows
          CustomWorkflow.run_custom_workflows(:document, self, :after_save)
        end

        def before_destroy_custom_workflows
          CustomWorkflow.run_custom_workflows(:document, self, :before_destroy)
        end

        def after_destroy_custom_workflows
          CustomWorkflow.run_custom_workflows(:document, self, :after_destroy)
        end
    end

    module DocumentsControllerPatch
      extend ActiveSupport::Concern
      include RedmineCustomWorkflows::Concerns::ControllerPatch     

      included do 
        # after_action :after_edit_action_custom_workflows , only: [:new, :edit]
        private
          def after_action_custom_workflows
            CustomWorkflow.run_custom_workflows(:document, @document, :after_action)
          end

      end
      # class_methods do
        
      # end
    end
  end
end



# Apply patch
RedmineExtensions::PatchManager.register_model_patch 'Document',
  'RedmineCustomWorkflows::Patches::DocumentPatch'

RedmineExtensions::PatchManager.register_controller_patch 'DocumentsController',
  'RedmineCustomWorkflows::Patches::DocumentsControllerPatch'