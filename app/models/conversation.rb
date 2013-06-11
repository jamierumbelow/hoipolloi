# A conversation -- a series of tweets in order
class Conversation < ActiveRecord::Base
  belongs_to :user
  has_many :tweets

  class << self
    # There's gotta be a better way of doing this...
    def recent_conversations limit, current_user, newer_than = false
      scope = self.order('(SELECT MAX(tweeted_at) FROM tweets WHERE (conversations.id=tweets.conversation_id)) DESC')
                  .limit(10)
                  .includes(:tweets)
                  .where("tweets.from_name != '#{current_user.nickname}'")
                  .where(user_id: current_user)

      if newer_than
        scope = scope.where("conversations.created_at > '#{newer_than || '0000-00-00 00:00:00'}'")
      end

      scope.all
    end

    def most_recent_conversation current_user
      self.order('created_at DESC').where(user_id: current_user).limit(1).first
    end
  end

  # Grab a sentence of the the list of people we're conversing with
  def from_names(current_user)
    get_from_names(current_user).to_sentence
  end

  # Same as above, only not a setence and with @ symbols
  def from_names_at(current_user)
    get_from_names(current_user).map { |n| "@#{n}" }.join(' ')
  end

  # Grab a snippet of the conversation
  def snippet
    tweets.order('tweeted_at DESC').first.text
  end

  private

  # Fetch all the tweeter's names
  def get_from_names(current_user)
    tweets.where("tweets.from_name != '#{current_user}'").map(&:from_name).uniq
  end
end
