require 'rails_helper'

RSpec.describe Api::V1::WebhooksController, type: :controller do
  let(:valid_create_card_payload) do
    {
      "action" => {
        "type" => "createCard",
        "data" => {
          "card" => {
            "id" => "trello123",
            "name" => "New Card",
            "desc" => "A new card created via Trello"
          },
          "list" => {
            "id" => "trello_list_one"
          }
        }
      }
    }.to_json
  end

  let(:valid_update_card_payload) do
    {
      "action" => {
        "type" => "updateCard",
        "data" => {
          "card" => {
            "id" => "trello123",
            "name" => "Updated Card",
            "desc" => "Updated description"
          }
        }
      }
    }.to_json
  end

  let(:valid_delete_card_payload) do
    {
      "action" => {
        "type" => "deleteCard",
        "data" => {
          "card" => {
            "id" => "trello123"
          }
        }
      }
    }.to_json
  end

  let(:invalid_payload) { "invalid_json" }

  describe "GET #show" do
    before { allow(controller).to receive(:validate_trello_webhook).and_return(true) }

    it "returns HTTP 200 status for webhook setup" do
      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    before { allow(controller).to receive(:validate_trello_webhook).and_return(true) }

    context "with valid createCard payload" do
      it "creates a new card in the database" do
        expect {
          post :create, body: valid_create_card_payload
        }.to change(Card, :count).by(1)

        expect(response).to have_http_status(:ok)

        card = Card.last
        expect(card.trello_card_id).to eq("trello123")
        expect(card.name).to eq("New Card")
        expect(card.description).to eq("A new card created via Trello")
      end
    end

    context "with valid updateCard payload" do
      let!(:existing_card) { Card.create!(trello_card_id: "trello123", name: "Old Name", description: "Old Description", trello_list_id: "trello_list_one") }

      it "updates an existing card in the database" do
        expect {
          post :create, body: valid_update_card_payload
        }.not_to change(Card, :count)

        expect(response).to have_http_status(:ok)

        card = Card.find_by(trello_card_id: "trello123")
        expect(card.name).to eq("Updated Card")
        expect(card.description).to eq("Updated description")
      end
    end

    context "with valid deleteCard payload" do
      let!(:existing_card) { Card.create!(trello_card_id: "trello123", name: "Old Name", description: "Old Description", trello_list_id: "trello_list_one") }

      it "deletes the card from the database" do
        expect {
          post :create, body: valid_delete_card_payload
        }.to change(Card, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(Card.find_by(trello_card_id: "trello123")).to be_nil
      end
    end

    context "with invalid JSON payload" do
      it "returns HTTP 400 status" do
        post :create, body: invalid_payload
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with unhandled action type" do
      let(:unhandled_payload) do
        {
          "action" => {
            "type" => "unknownAction",
            "data" => {}
          }
        }.to_json

        it "logs the unhandled action type and returns HTTP 200 status" do
          expect(Rails.logger).to receive(:info).with("Unhandled Trello event type: unknownAction")
          post :create, body: unhandled_payload
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
