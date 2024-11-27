class Card < ApplicationRecord
  validates :name, presence: true

  belongs_to :list, primary_key: :trello_list_id, foreign_key: :trello_list_id

  def push_to_trello
    trello_api_key = ENV['TRELLO_KEY']
    trello_token = ENV['TRELLO_TOKEN']

    url = 'https://api.trello.com/1/cards'

    params = {
      idList: trello_list_id,
      key: trello_api_key,
      token: trello_token,
      name: name,
      desc: description,
    }

    params[:due] = due_date.strftime("%Y-%m-%d") if due_date.present?

    begin
      response = RestClient.post("#{url}?#{URI.encode_www_form(params)}", {}, { accept: :json })
      JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Trello API Error: #{e.response}"
      nil
    rescue => e
      Rails.logger.error "Unexpected Error: #{e.message}"
      nil
    end
  end
end
