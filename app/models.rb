require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development")

class User
  include DataMapper::Resource

  has n, :mentions

  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :created_at, DateTime
end

class Conversation
  include DataMapper::Resource

  belongs_to :user
  has n, :mentions

  property :id,   Serial
  property :read, Boolean
end

class Mention
  include DataMapper::Resource

  belongs_to :conversation
  belongs_to :user

  property :id,                    Serial
  property :tweet_id,              String
  property :in_reply_to_status_id, String
  property :text,                  Text
  property :tweeted_at,            DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!