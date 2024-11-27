class List < ApplicationRecord
  validates :name, presence: true
  validates :trello_list_id, presence: true

  has_many :cards, primary_key: :trello_list_id, foreign_key: :trello_list_id, dependent: :destroy

  after_commit :broadcast_all_lists

  private

  def broadcast_all_lists
    # IMPR: send only changed lists
    ActionCable.server.broadcast(
      "lists",
      List.includes(:cards).as_json(include: :cards)
    )
  end
end
