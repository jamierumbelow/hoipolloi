class ConversationsController < ApplicationController

  def index
    @conversations = Conversation.recent_conversations 10, current_user
    @auto_refresh = true
  end

  def show
    @conversation = Conversation.find params[:id]
    @conversation.update_attributes :read => true
  end

  def reply
    @conversation = Conversation.find params[:id]

    tweet = Twitter.update params[:reply], :in_reply_to_status_id => @conversation.tweets.order('tweeted_at DESC').first.tweet_id
    @conversation.tweets.create :text => tweet.text, :tweet_id => tweet.id, :user => @current_user, :from_name => @current_user.nickname, :tweeted_at => tweet.created_at

    redirect_to conversation_url(@conversation)
  end

  def read
    if params[:mark_as_read]
      Conversation.update_all({ :read => true }, { :id => params[:conversations] })
    elsif params[:mark_as_unread]
      Conversation.update_all({ :read => false }, { :id => params[:conversations] })
    end
    redirect_to conversations_url
  end

end
