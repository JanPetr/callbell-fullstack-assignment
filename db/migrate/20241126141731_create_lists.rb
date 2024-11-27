class CreateLists < ActiveRecord::Migration[6.1]
  def change
    create_table :lists do |t|
      t.string :name, null: false
      t.string :trello_list_id, null: false

      t.timestamps
    end
  end
end
