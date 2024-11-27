class List < ApplicationRecord
  validates :name, presence: true
  validates :trello_list_id, presence: true

  has_many :cards, primary_key: :trello_list_id, foreign_key: :trello_list_id, dependent: :destroy
end
