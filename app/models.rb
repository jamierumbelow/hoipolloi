require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development"

class User < ActiveRecord::Base
  has_many :tweets
end

class Conversation < ActiveRecord::Base
  belongs_to :user
  has_many :tweets

  class << self
    # There's gotta be a better way of doing this...
    def recent_conversations limit, current_user, newer_than = false
      scope = self.order('(SELECT tweeted_at FROM tweets WHERE (conversations.id=tweets.conversation_id) LIMIT 1 ORDER BY tweeted_at DESC) DESC')
                  .limit(10)
                  .includes(:tweets)
                  .where("tweets.from_name != '#{current_user}'")
                  .where("conversations.created_at > '#{newer_than || '0000-00-00 00:00:00'}'")
      scope.all
    end

    def most_recent_conversation
      self.order('created_at DESC').limit(1).first
    end
  end

  def from_names(current_user)
    get_from_names(current_user).to_sentence
  end

  def from_names_at(current_user)
    get_from_names(current_user).map { |n| "@#{n}" }.join(' ')
  end

  def snippet
    tweets.order('tweeted_at DESC').first.text
  end

  private

  def get_from_names(current_user)
    tweets.where("tweets.from_name != '#{current_user}'").map(&:from_name).uniq
  end
end

class Tweet < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
end