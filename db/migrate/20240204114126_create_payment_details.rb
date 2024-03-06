class CreatePaymentDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_details do |t|
      t.references :payment, foreign_key: true
      t.string :participant, null: false
      t.integer :fee, default: 0
      t.boolean :is_paid, default: false

      t.timestamps
    end
  end
end
