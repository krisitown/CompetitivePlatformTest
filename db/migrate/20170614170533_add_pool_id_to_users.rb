class AddPoolIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :matchmaking_pool_id, :integer
  end
end
