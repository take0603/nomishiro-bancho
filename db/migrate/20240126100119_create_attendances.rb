class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.references :event, null: false, foreign_key: true
      t.references :schedule, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.integer :answer, default: 0

      t.timestamps
    end
  end
end
