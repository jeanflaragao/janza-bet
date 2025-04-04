class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :owner
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
