class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :auto_refresh
  before_action :configure_twitter

private
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    end
  end

  def auto_refresh
    @auto_refresh
  end

  def configure_twitter
    if current_user && session[:access_token] && session[:access_token_secret]
      Twitter.configure do |config|
        config.consumer_key = ENV.fetch('TWITTER_CONSUMER_KEY')
        config.consumer_secret = ENV.fetch('TWITTER_CONSUMER_SECRET')
        config.oauth_token = session[:access_token]
        config.oauth_token_secret = session[:access_token_secret]
      end
    end
  end
end
