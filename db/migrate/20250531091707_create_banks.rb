class CreateBanks < ActiveRecord::Migration[8.0]
  def change
    create_table :banks do |t|
      t.date :month
      t.decimal :bank_value
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
