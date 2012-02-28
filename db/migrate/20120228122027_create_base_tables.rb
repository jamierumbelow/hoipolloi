class CreateBaseTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :name
      t.string :nickname

      t.timestamps
    end

    create_table :conversations do |t|
      t.integer :user_id
      t.boolean :read

      t.timestamps
    end

    add_index :conversations, :user_id

    create_table :tweets do |t|
      t.integer :user_id
      t.integer :conversation_id

      t.integer :tweet_id
      t.string :from_name
      t.text :text
      t.datetime :tweeted_at

      t.timestamps
    end

    add_index :tweets, :user_id
    add_index :tweets, :tweet_id, :unique => true
    add_index :tweets, :conversation_id
  end
end
