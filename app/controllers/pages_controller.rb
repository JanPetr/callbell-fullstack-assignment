class PagesController < ActionController::Base
  def index
    render file: Rails.root.join('public/packs/index.html')
  end

  def frontend_config
    render json: {
      api_key: ENV['FE_API_KEY'],
    }
  end
end
