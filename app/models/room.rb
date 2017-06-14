class Room < ActiveRecord::Base
    validates :name, presence: true, length: { minimum: 5, maximum: 30 }
    validates :coins_per_player, presence: true
end
