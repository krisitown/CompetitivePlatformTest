class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :player_one_id
      t.integer :player_two_id
      t.integer :coins_per_player
      t.string :name
      t.integer :winner_id

      t.timestamps null: false
    end
  end
end
