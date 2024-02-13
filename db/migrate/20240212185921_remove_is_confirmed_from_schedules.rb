class RemoveIsConfirmedFromSchedules < ActiveRecord::Migration[7.1]
  def change
    remove_column :schedules, :is_confirmed, :boolean
  end
end
