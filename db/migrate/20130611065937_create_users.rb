class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid, limit: 8
      t.string :name
      t.string :nickname

      t.timestamps
    end
    add_index :users, :uid
  end
end
