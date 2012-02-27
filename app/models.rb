require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development")

class User
  include DataMapper::Resource

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

  property :id,         Serial
  property :tweet_id,   String
  property :text,       Text
  property :tweeted_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!