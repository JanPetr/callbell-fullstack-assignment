class AddFieldsToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :name, :string, null: false
    add_column :cards, :description, :text
    add_column :cards, :due_date, :datetime
    add_column :cards, :trello_card_id, :string
  end
end
