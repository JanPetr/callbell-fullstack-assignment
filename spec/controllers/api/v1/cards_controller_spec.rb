require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::V1::CardsController, type: :controller do
  fixtures :cards, :lists

  describe "GET #index" do
    before { allow(controller).to receive(:verify_api_key).and_return(true) }

    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "returns all cards" do
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]['cards'].size).to eq(3)
    end
  end

  describe "POST /create" do
    before { allow(controller).to receive(:verify_api_key).and_return(true) }

    context "with valid attributes" do
      it "creates a new card" do
        list = lists(:list_one)
        params = {
          name: "New Trello Card",
          description: "A description for the new card.",
          due_date: "2024-12-06",
          id_list: list.trello_list_id,
        }

        stub_request(:post, "https://api.trello.com/1/cards")
          .with(
            query: {
              "idList" => list.trello_list_id,
              "key" => ENV['TRELLO_KEY'],
              "token" => ENV['TRELLO_TOKEN'],
              "name" => params[:name],
              "desc" => params[:description],
              "due" => params[:due_date],
            },
            headers: { 'Accept'=>'application/json' }
          )
          .to_return(
            status: 200,
            body: { id: "trello123" }.to_json
          )

        expect {
          post :create, params: { card: params, id_list: params[:id_list] }
        }.to change(Card, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['name']).to eq("New Trello Card")
        expect(json['data']['trello_card_id']).to eq("trello123")
      end

      it "creates a new card even when due_date is not a date" do
        list = lists(:list_one)
        params = {
          name: "New Trello Card",
          description: "A description for the new card.",
          due_date: "hello",
          id_list: list.trello_list_id,
        }

        stub_request(:post, "https://api.trello.com/1/cards")
          .with(
            query: {
              "idList" => list.trello_list_id,
              "key" => ENV['TRELLO_KEY'],
              "token" => ENV['TRELLO_TOKEN'],
              "name" => params[:name],
              "desc" => params[:description],
            },
            headers: { 'Accept'=>'application/json' }
          )
          .to_return(
            status: 200,
            body: { id: "trello123" }.to_json
          )

        expect {
          post :create, params: { card: params, id_list: params[:id_list] }
        }.to change(Card, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['name']).to eq("New Trello Card")
        expect(json['data']['due_date']).to eq(nil)
      end

      it "id doesn't crate a new card when Trello returns error" do
        list = lists(:list_one)
        params = {
          name: "New Trello Card",
          description: "A description for the new card.",
          due_date: "hello",
          id_list: list.trello_list_id,
        }

        stub_request(:post, "https://api.trello.com/1/cards")
          .with(
            query: {
              "idList" => list.trello_list_id,
              "key" => ENV['TRELLO_KEY'],
              "token" => ENV['TRELLO_TOKEN'],
              "name" => params[:name],
              "desc" => params[:description],
            },
            headers: { 'Accept'=>'application/json' }
          )
          .to_return(
            status: 500,
            body: { id: "trello123" }.to_json
          )

        expect {
          post :create, params: { card: params, id_list: params[:id_list] }
        }.to change(Card, :count).by(0)

        expect(response).to have_http_status(:failed_dependency)
      end
    end

    context "with invalid attributes" do
      it "does not create a new card" do
        list = lists(:list_one)
        post :create, params: { card: { name: "" }, id_list: list.trello_list_id, }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "return invalid dependency for non existent list" do
        post :create, params: { card: { name: "" }, id_list: "foobarbaz", }

        expect(response).to have_http_status(:failed_dependency)
      end
    end
  end
end
