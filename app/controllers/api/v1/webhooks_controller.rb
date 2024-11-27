class Api::V1::WebhooksController < ApplicationController
  before_action :validate_trello_webhook

  def show # Used for setting up the webhook
    head :ok
  end

  def create
    payload = JSON.parse(request.body.read)

    case payload['action']['type']
    when 'createCard'
      handle_create_card(payload)
    when 'updateCard'
      handle_update_card(payload)
    when 'deleteCard'
      handle_delete_card(payload)
    when 'createList'
      handle_create_list(payload)
    else
      Rails.logger.info("Unhandled Trello event type: #{payload['action']['type']}")
    end

    # IMPR: handle archiving, images, delete lists ...

    head :ok
  rescue JSON::ParserError
    Rails.logger.error("Invalid JSON payload from Trello")
    head :bad_request
  end

  private

  def validate_trello_webhook
    callback_url = request.url
    trello_signature = request.headers['X-Trello-Webhook']
    request_body = request.body.read
    secret = ENV['TRELLO_SECRET']

    digest = OpenSSL::HMAC.digest('sha1', secret, request_body + callback_url)
    computed_hash = Base64.strict_encode64(digest)

    if computed_hash != trello_signature
      Rails.logger.warn("Invalid Trello webhook signature")
      head :unauthorized
    end
  end

  def handle_create_card(payload)
    card_data = payload['action']['data']['card']

    return if Card.find_by(trello_card_id: card_data['id']).present?

    Card.create!(
      trello_card_id: card_data['id'],
      name: card_data['name'],
      description: card_data['desc'],
      due_date: card_data['due'],
      trello_list_id: payload['action']['data']['list']['id']
    )

    Rails.logger.info("Card created: #{card_data['id']}")
  end

  def handle_update_card(payload)
    card_data = payload['action']['data']['card']
    card = Card.find_by(trello_card_id: card_data['id'])
    return if card.blank?

    update_data = {
      name: card_data['name'],
      due_date: card_data['due'],
    }

    update_data[:description] = card_data['desc'] unless card_data['desc'].nil?

    card.update!(update_data)
  end

  def handle_delete_card(payload)
    card_data = payload['action']['data']['card']
    card = Card.find_by(trello_card_id: card_data['id'])

    card.destroy! if card.present?
  end

  def handle_create_list(payload)
    list_data = payload['action']['data']['list']

    List.create!(
      trello_list_id: list_data['id'],
      name: list_data['name'],
    )

    Rails.logger.info("List created: #{list_data['id']}")
  end
end
