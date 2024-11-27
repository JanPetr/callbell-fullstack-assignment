class ListsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "lists"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
