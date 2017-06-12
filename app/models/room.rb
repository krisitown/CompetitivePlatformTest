class Room < ActiveRecord::Base
    validates :name, presence: true, length: { minimum: 5, maximum: 20 }
    validates :coins_per_player, presence: true
end
