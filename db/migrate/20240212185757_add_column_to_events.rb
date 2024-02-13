class AddColumnToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :date, :datetime
    add_column :events, :deadline, :date
  end
end
