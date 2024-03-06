class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_name, null: false
      t.text :explanation

      t.timestamps
    end
  end
end
