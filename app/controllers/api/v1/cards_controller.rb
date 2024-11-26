class Api::V1::CardsController < ApplicationController
  def index
    cards = Card.all
    render json: cards, status: :ok
  end

  def create
    card_params = params.permit(:name, :description, :due_date)

    card = Card.new(card_params)

    unless card.valid?
      head :unprocessable_entity
      return
    end

    result = card.push_to_trello
    if result.nil?
      head :failed_dependency
      return
    end

    card.trello_card_id = result['id']
    card.save!

    render json: { ok: true, data: card }, status: :created
  end
end
