class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :user_id
      t.integer :conversation_id
      t.integer :tweet_id, limit: 8

      t.string :from_name
      t.text :text
      t.datetime :tweeted_at

      t.timestamps
    end
    add_index :tweets, :user_id
    add_index :tweets, :tweet_id, unique: true
    add_index :tweets, :conversation_id
  end
end
