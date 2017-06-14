class MatchmakingController < ApplicationController
    def join
        user = User.find(session[:current_user]['id'])
        user.matchmaking_pool_id = 1
        user.save
        stake = params[:stake].to_i
        pair_up(stake)
        render :nothing => true, :status => 204
    end
    
    def leave
        user = User.find(session[:current_user]['id'])
        user.matchmaking_pool_id = -1
        user.save
        render :nothing => true, :status => 204
    end
    
    def user_in_room
        rooms = Room.where('player_one_id=? OR player_two_id=?', session[:current_user]['id'], session[:current_user]['id'])
        if rooms.size == 0
            render nothing: true, status: 404
        else
            render json: { room: rooms.first }
        end
    end
        
        
    private 
        def pair_up(stake)
            users = User.where(:matchmaking_pool_id => 1)
            until users.size < 2 do
                playerOne = users[0]
                playerTwo = users[1]
                room = Room.create(player_one_id: playerOne.id, player_two_id: playerTwo.id,
                    coins_per_player: stake, name: "Matchmaking Game Room",
                    player_count: 2)
                room.save
                #remove paired users from pool
                playerOne.matchmaking_pool_id = -1
                playerTwo.matchmaking_pool_id = -1
                
                playerOne.save
                playerTwo.save
                
                users = users.drop(2)
            end
        end
end
