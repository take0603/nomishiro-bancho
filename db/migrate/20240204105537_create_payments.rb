class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :event, foreign_key: true
      t.string :payment_name, null: false
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
