class HomeController < ApplicationController
  def index
    if current_user
      redirect_to conversations_url
    end
  end
end
