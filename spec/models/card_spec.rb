require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Card, type: :model do
  fixtures :cards, :lists

  describe 'validations' do
    it 'validates presence of name' do
      card = Card.new(name: nil)
      expect(card.valid?).to be_falsey
      expect(card.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a list with matching trello_list_id' do
      list = List.create(name: 'Test List', trello_list_id: '12345')
      card = Card.create(name: 'Test Card', trello_card_id: 'card123', trello_list_id: '12345')

      expect(card.list).to eq(list)
    end
  end

  describe '#push_to_trello' do
    it 'sends a POST request to Trello API and returns the response' do
      card = cards(:card_one)

      stub_request(:post, "https://api.trello.com/1/cards")
        .with(query: hash_including(idList: card.trello_list_id, name: card.name))
        .to_return(status: 200, body: { id: 'fake_card_id' }.to_json, headers: { 'Content-Type' => 'application/json' })

      response = card.push_to_trello

      expect(response).to include('id' => 'fake_card_id')
    end

    it 'logs an error and returns nil when Trello API fails' do
      card = cards(:card_one)

      stub_request(:post, "https://api.trello.com/1/cards")
        .with(query: hash_including(key: ENV['TRELLO_KEY'], token: ENV['TRELLO_TOKEN']))
        .to_return(status: 400, body: 'Bad Request')

      expect(Rails.logger).to receive(:error).with(/Trello API Error/)
      response = card.push_to_trello
      expect(response).to be_nil
    end
  end

  describe '#delete_from_trello' do
    it 'sends a DELETE request to Trello API and returns the response' do
      card = cards(:card_one)

      stub_request(:delete, "https://api.trello.com/1/cards/#{card.trello_card_id}")
        .with(query: hash_including(key: ENV['TRELLO_KEY'], token: ENV['TRELLO_TOKEN']))
        .to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })

      response = card.delete_from_trello

      expect(response).to include('success' => true)
    end

    it 'does not send a DELETE request when trello_card_id is blank' do
      card = cards(:card_one)
      card.trello_card_id = nil

      expect(RestClient).not_to receive(:delete)
      response = card.delete_from_trello
      expect(response).to be_nil
    end
  end

  describe 'after_commit callback: #broadcast_all_lists' do
    it 'broadcasts all lists with their cards' do
      list = lists(:list_one)
      card = Card.new(name: 'Test Card', trello_card_id: 'card123', trello_list_id: list.trello_list_id)

      expect(ActionCable.server).to receive(:broadcast).with("lists", anything)

      card.save
    end
  end
end
