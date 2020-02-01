class AddAfterActionCustomWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_workflows, :after_action, :text, :null => true
  end
end
