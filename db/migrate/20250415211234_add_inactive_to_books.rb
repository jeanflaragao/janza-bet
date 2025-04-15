class AddInactiveToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :inactive, :boolean, default: false, null: false
  end
end
