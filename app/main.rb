require 'bundler/setup'

require 'sinatra'

require 'twitter'

require 'omniauth'
require 'omniauth-twitter'

require './app/models'
require './config/twitter'

module HoiPolloi
  class App < Sinatra::Base
    set :root, Proc.new { File.expand_path File.join(File.dirname(__FILE__), '../') }
    set :views, Proc.new { File.join root, 'app/views' }

    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :twitter, HoiPolloi.configuration[:consumer_key], HoiPolloi.configuration[:consumer_secret]
    end

    before do
      unless session[:username].nil?
        Twitter.configure do |config|
          config.consumer_key = HoiPolloi.configuration[:consumer_key]
          config.consumer_secret = HoiPolloi.configuration[:consumer_secret]
          config.oauth_token = session[:access_token]
          config.oauth_token_secret = session[:access_token_secret]
        end
      end
    end

    get '/auth/:name/callback' do
      auth = request.env["omniauth.auth"]
      
      session[:access_token] = auth['credentials']['token']
      session[:access_token_secret] = auth['credentials']['secret']
      session[:username] = auth['info']['nickname']

      redirect '/twitter/test'
    end

    get '/' do
      erb :index
    end

    get '/twitter/test' do
      erb :twitter_test
    end
  end
end