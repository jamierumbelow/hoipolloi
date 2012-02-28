require 'dm-core'
require 'dm-migrations'
require 'dm-ar-finders'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development")

class User
  include DataMapper::Resource

  has n, :tweets

  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :created_at, DateTime
end

class Conversation
  include DataMapper::Resource

  belongs_to :user
  has n, :tweets

  property :id,   Serial
  property :read, Boolean
end

class Tweet
  include DataMapper::Resource

  belongs_to :conversation
  belongs_to :user

  property :id,                    Serial
  property :from_name,             String
  property :tweet_id,              String
  property :in_reply_to_status_id, String
  property :text,                  Text
  property :tweeted_at,            DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!