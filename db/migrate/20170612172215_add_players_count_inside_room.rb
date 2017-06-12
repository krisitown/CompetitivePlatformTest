class AddPlayersCountInsideRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :player_count, :integer
  end
end
