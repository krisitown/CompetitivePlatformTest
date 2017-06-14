class CreateMatchmakingPools < ActiveRecord::Migration
  def change
    create_table :matchmaking_pools do |t|

      t.timestamps null: false
    end
  end
end
