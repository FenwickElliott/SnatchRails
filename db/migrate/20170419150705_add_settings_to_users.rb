class AddSettingsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :settings, :string
  end
end
