class AddRelationships < ActiveRecord::Migration[6.1]
  def change
    add_index :lists, :trello_list_id, unique: true

    add_column :cards, :trello_list_id, :string, null: false
    add_index :cards, :trello_list_id
  end
end
