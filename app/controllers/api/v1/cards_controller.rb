class Api::V1::CardsController < ApplicationController
  def index
    lists = List.includes(:cards).all
    render json: lists.as_json(include: :cards), status: :ok
  end

  def create
    card_params = params.permit(:name, :description, :due_date, :id_list)

    list = List.find_by(trello_list_id: card_params[:id_list])
    if list.blank?
      head :failed_dependency
      return
    end

    card_params.delete('id_list')
    card_params[:trello_list_id] = list.trello_list_id

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
