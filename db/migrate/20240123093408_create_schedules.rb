class CreateSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :schedules do |t|
      t.references :event, null: false, foreign_key: true
      t.datetime :schedule_date, null: false
      t.boolean :is_confirmed, default: false

      t.timestamps
    end
  end
end
