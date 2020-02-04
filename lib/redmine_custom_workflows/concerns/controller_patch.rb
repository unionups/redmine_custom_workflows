module RedmineCustomWorkflows
  module Concerns
    module ControllerPatch
      extend ActiveSupport::Concern
      included do 
        # after_action :after_edit_action_custom_workflows , only: [:new, :edit]
        private
          def render *args
            after_action_custom_workflows if [:edit, :new, :settings, :refresh].include?(action_name.to_sym)
            super 
          end
      end
      # class_methods do
        
      # end
    end
  end
end