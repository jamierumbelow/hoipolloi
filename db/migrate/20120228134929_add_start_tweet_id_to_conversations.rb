class AddStartTweetIdToConversations < ActiveRecord::Migration
  def change
  	add_column :conversations, :start_tweet_id, 'BIGINT'
  	add_index :conversations, :start_tweet_id, :unique => true
  end
end
