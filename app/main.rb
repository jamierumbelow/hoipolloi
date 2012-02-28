require 'bundler/setup'

require 'sinatra'

require 'twitter'

require 'omniauth'
require 'omniauth-twitter'

require './app/models'
require './config/twitter'

module HoiPolloi
  class App < Sinatra::Base
    attr_accessor :current_user

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

        @current_user = User.find session[:user_id]
      end
    end

    get '/auth/:name/callback' do
      auth = request.env["omniauth.auth"]
      
      session[:access_token] = auth['credentials']['token']
      session[:access_token_secret] = auth['credentials']['secret']
      session[:username] = auth['info']['nickname']

      user = User.find_or_create_by_uid :uid => auth["uid"],
                                        :nickname => auth["info"]["nickname"], 
                                        :name => auth["info"]["name"],
                                        :created_at => Time.now
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
      @conversations = Conversation.find_by_sql "SELECT conversations.*
                                                 FROM conversations
                                                 JOIN tweets ON tweets.conversation_id = conversations.id 
                                                 GROUP BY conversations.id
                                                 HAVING COUNT(tweets.id) > 1"

      erb :'conversations/index'
    end

    # Go and rape Twitter for the user's latest tweets,
    # and return a lovely HTML snippet for us
    post '/rape' do
      
      # First, we're going to grab the user's recent tweets and import them into
      # the database. We're doing this so that we can create conversations around them.
      if current_user.tweets.count > 0
        my_tweets = Twitter.user_timeline :count => 200, :since_id => current_user.tweets.order('tweeted_at DESC').first.tweet_id
      else
        my_tweets = Twitter.user_timeline :count => 200
      end

      # We now want to loop through our tweets and bring them into the database.
      import_into_database my_tweets

      # Now, let's do the same sort of thing for our mentions!
      current_tweet = current_user.tweets.order('tweeted_at DESC').first

      if current_tweet.nil?
        mentions = Twitter.mentions :count => 200, :since_id => current_tweet.tweet_id
      else
        mentions = Twitter.mentions :count => 200
      end

      import_into_database mentions

      # Finally, grab our 'conversing' conversations, that is, our conversations
      # with > 1 tweet in them.
      @conversations = Conversation.find_by_sql "SELECT conversations.*
                                                 FROM conversations
                                                 JOIN tweets ON tweets.conversation_id = conversations.id 
                                                 GROUP BY conversations.id
                                                 HAVING COUNT(tweets.id) > 1"

      # ...and render out our view :)
      erb :'conversations/rows', :layout => false
    end

    private

    # Import our tweets into the database. But be clever about it, yeah? Check that
    # if we're replying to a tweet and we have that tweet in our database, we add it
    # to that conversation, or if we don't, we create a new conversation for it.
    def import_into_database tweets
      tweets.each do |tweet|
        unless tweet.in_reply_to_status_id.nil?

          # I've been battling DataMapper all night. I know this is horrible, and that Satan will
          # banish me to Hell for this. Oh! I can smell the burning flesh, the intoxicating smoke,
          # the reams and reams of Dan Brown novels. But alas, my hands are tied.
          #
          # conversation = Conversation.first :limit => 1, :tweets => { :tweet_id => tweet.in_reply_to_status_id }
          conversation_tweet = Tweet.find_by_tweet_id(tweet.in_reply_to_status_id, :include => [ :conversation ])
          
          unless conversation_tweet.nil?

            # If we have any existing tweets, we have a conversation!
            conversation = conversation_tweet.conversation
            conversation.update_attributes :read => 0
          else

            # Otherwise, we need to create a new conversation
            conversation = Conversation.create! :read => 0, :user => current_user
          end
        else

          conversation = Conversation.create! :read => 0, :user => current_user
        end
        
        # Import the tweet into the database.
        Tweet.create! :tweet_id => tweet.id,
                      :from_name => tweet.user.screen_name,
                      :user => current_user,
                      :conversation_id => conversation.id,
                      :text => tweet.text,
                      :tweeted_at => tweet.created_at
      end
    end
  end
end