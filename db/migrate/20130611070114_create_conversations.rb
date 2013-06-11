class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :user_id
      t.boolean :read
      t.timestamps
      t.integer :start_tweet_id, limit: 8
    end
    add_index :conversations, :user_id
    add_index :conversations, :start_tweet_id, unique: true
  end
end
