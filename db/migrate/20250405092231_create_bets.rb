class CreateBets < ActiveRecord::Migration[8.0]
  def change
    create_table :bets do |t|
      t.date :event_date
      t.string :game
      t.text :bet
      t.decimal :stake
      t.decimal :odd
      t.string :status
      t.references :book, null: false, foreign_key: true
      t.references :tipster, null: false, foreign_key: true
      t.decimal :result

      t.timestamps
    end
  end
end
