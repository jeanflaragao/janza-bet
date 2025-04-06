class CreateDailyBalances < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_balances do |t|
      t.references :book, null: false, foreign_key: true
      t.decimal :balance
      t.date :date

      t.timestamps
    end
  end
end
