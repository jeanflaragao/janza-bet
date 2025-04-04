class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :book, null: false, foreign_key: true
      t.string :transaction_type
      t.datetime :date

      t.timestamps
    end
  end
end
