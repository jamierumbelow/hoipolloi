require 'bundler/setup'

require 'sinatra'

require 'twitter'

require 'omniauth'
require 'omniauth-twitter'

require './app/models'
require './lib/twitter_raper'
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
      unless session[:user_id].nil?
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

      user = User.first_or_create({ :uid => auth["uid"] },
                                  { :uid => auth["uid"],
                                    :nickname => auth["info"]["nickname"], 
                                    :name => auth["info"]["name"],
                                    :created_at => Time.now })
      session[:user_id] = user.id

      redirect '/'
    end

    get '/auth/logout' do
      session[:user_id] = session[:username] = session[:access_token] = session[:access_token_secret] = nil

      redirect '/'
    end

    get '/' do
      if session[:user_id].nil?
        erb :index
      else
        redirect url('/conversations')
      end
    end

    get '/conversations' do
      erb :'conversations/index'
    end

    # go and rape Twitter for the user's latest tweets,
    # and return a lovely HTML snippet for us
    get '/rape' do
      current_user = User.get session[:user_id]
      current_tweet = current_user.mentions( :order => [ :tweeted_at.desc ], :limit => 1 ).last || false

      if current_tweet
        mentions = Twitter.mentions :count => 200, :since_id => current_tweet.tweet_id
      else
        mentions = Twitter.mentions :count => 200
      end
      
      mentions.each do |mention|
        unless mention.in_reply_to_status_id.nil?
          conversation = Conversation.first :limit => 1, :mentions => { :tweet_id => mention.in_reply_to_status_id }

          unless conversation.nil?
            conversation.update! :read => 0
          else
            conversation = Conversation.create! :read => 0, :user => current_user
          end
        else
          conversation = Conversation.create! :read => 0, :user => current_user
        end
        
        Mention.create! :tweet_id => mention.id,
                        :user => current_user,
                        :conversation_id => conversation.id,
                        :text => mention.text,
                        :tweeted_at => mention.created_at
      end

      @conversations = Conversation.all

      erb :'conversations/rows', :layout => false
    end
  end
end