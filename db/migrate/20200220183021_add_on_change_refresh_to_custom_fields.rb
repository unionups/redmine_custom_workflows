class AddOnChangeRefreshToCustomFields  < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :on_change_refresh, :boolean, :default => false
  end
end