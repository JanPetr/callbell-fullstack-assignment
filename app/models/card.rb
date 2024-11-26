class Card < ApplicationRecord
  validates :name, presence: true
  # validates :id_list, presence: true

  def push_to_trello
    trello_api_key = ENV['TRELLO_KEY']
    trello_token = ENV['TRELLO_TOKEN']
    list_id = "6745aff80272c27d1c71bbf6"

    url = 'https://api.trello.com/1/cards'

    params = {
      idList: list_id,
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
