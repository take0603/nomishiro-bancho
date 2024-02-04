class CreateMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :members do |t|
      t.string :member_name, null: false

      t.timestamps
    end
  end
end
