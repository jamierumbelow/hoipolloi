require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development"

class User < ActiveRecord::Base
  has_many :tweets
end

class Conversation < ActiveRecord::Base
  belongs_to :user
  has_many :tweets

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