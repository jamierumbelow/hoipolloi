class ChangeTweetIdColumn < ActiveRecord::Migration
  def self.up
  	change_column :tweets, :tweet_id, 'BIGINT UNSIGNED'
  end

  def self.down
  	change_column :tweets, :tweet_id, :integer, :length => 11
  end
end
