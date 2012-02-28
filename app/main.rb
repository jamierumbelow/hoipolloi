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
      @conversations = Conversation.recent_conversations 10, @current_user.nickname

      erb :'conversations/index'
    end

    get '/conversations/:id' do |id|
      @conversation = Conversation.find id
      @conversation.update_attributes :read => true

      erb :'conversations/show'
    end

    post '/conversations/:id/reply' do |id|
      @conversation = Conversation.find id

      tweet = Twitter.update params[:reply], :in_reply_to_status_id => @conversation.tweets.order('tweeted_at DESC').first.tweet_id
      @conversation.tweets.create :text => tweet.text, :tweet_id => tweet.id, :user => @current_user, :from_name => @current_user.nickname, :tweeted_at => tweet.created_at

      redirect "/conversations/#{id}"
    end

    # Go and rape Twitter for the user's latest tweets,
    # and return a lovely HTML snippet for us
    post '/rape' do
      
      # First, we're going to grab the user's recent tweets and import them into
      # the database. We're doing this so that we can create conversations around them.
      current_tweet = current_user.tweets.order('tweeted_at DESC').where('from_name' => current_user.nickname).first
      current_conversation = Conversation.most_recent_conversation

      unless current_tweet.nil?
        my_tweets = Twitter.user_timeline :since_id => current_tweet.tweet_id
      else
        my_tweets = Twitter.user_timeline 
      end

      # We now want to loop through our tweets and bring them into the database.
      import_into_database my_tweets

      # Now, let's do the same sort of thing for our mentions!
      current_mention = current_user.tweets.order('tweeted_at DESC').where("from_name != '#{current_user.nickname}'").first

      unless current_mention.nil?
        mentions = Twitter.mentions :since_id => current_mention.tweet_id
      else
        mentions = Twitter.mentions 
      end

      import_into_database mentions

      # Finally, grab our recent conversations
      @conversations = Conversation.recent_conversations 10, @current_user.nickname

      # ...and render out our view :)
      erb :'conversations/rows', :layout => false
    end

    private

    # Import our tweets into the database. But be clever about it, yeah? Check that
    # if we're replying to a tweet and we have that tweet in our database, we add it
    # to that conversation, or if we don't, we create a new conversation for it.
    def import_into_database tweets
      tweets.each do |tweet|
        begin
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
            else

              # Otherwise, we need to create a new conversation
              conversation = Conversation.create! :read => 0, :user => current_user, :start_tweet_id => tweet.id
            end
          else

            conversation = Conversation.create! :read => 0, :user => current_user, :start_tweet_id => tweet.id
          end
        
          # Import the tweet into the database.
          Tweet.create! :tweet_id => tweet.id,
                        :from_name => tweet.user.screen_name,
                        :user => current_user,
                        :conversation_id => conversation.id,
                        :text => tweet.text,
                        :tweeted_at => tweet.created_at
        rescue ActiveRecord::RecordNotUnique => e 
          # ignore the duplicate
        else
          conversation.update_attributes :read => 0
        end
      end
    end
  end
end