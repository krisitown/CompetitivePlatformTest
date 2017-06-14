class RoomsController < ApplicationController
    def new
        @room = Room.new
    end
    
    def create
        @room = Room.create(room_params)
        @room.player_one_id = session[:current_user]['id']
        @room.player_count = 1
        if @room.coins_per_player > User.find(session[:current_user]['id']).coins
            flash[:danger] = "You don't have enough coins!"
            @room.destroy
            redirect_to '/rooms/new'
        else
            if @room.save
                flash[:success] = "You have successfully created a room!"
                redirect_to room_path(@room)
            else
                flash[:danger] = "An error occured, please try again!"
                render 'new'
            end
        end
    end
    
    def index
        @rooms = Room.where('player_count != 0').paginate(:page => params[:page], :per_page => 5)
    end
    
    def show
        user = session[:current_user]
        @room = Room.find(params[:id])
        if @room.player_one_id != user['id'] && @room.player_two_id != user['id']
            flash[:danger] = "You do not have permission to enter this part of the application."
            redirect_to '/'
        end
        #show game room
    end
    
    def join
        user = session[:current_user]
        room = Room.find(params[:id])
        
        if User.find(user['id']).coins < room.coins_per_player
            flash[:danger] = "You do not have enough coins to enter this room"
            redirect_to '/'
        else
            #see if second spot is empty
            if room.player_two_id == nil
                #check if other spot is the same as you
                if room.player_one_id == nil || room.player_one_id != user['id']
                    #join room in second spot
                    room.player_two_id = user['id']
                    room.player_count += 1
                    room.save

                    redirect_to room_path(room)
                else
                    flash[:danger] = "You have already joined this room!"
                    redirect_to '/'
                end
            #see if first spot is empty    
            elsif room.player_one_id == nil
                #check if other spot is the same as you
                if room.player_two_id == nil || room.player_two_id != user['id']
                    #join room in first spot
                    room.player_one_id = user['id']
                    room.player_count += 1
                    room.save
                    
                    redirect_to room_path(room)
                else
                    flash[:danger] = "You have already joined this room!"
                    redirect_to '/'
                end
            #room is full
            else
                flash[:danger] = "The room is full!"
                redirect_to '/'
            end
        end
    end    
        
        def leave
            user = session[:current_user]
            room = Room.find_by_id(params[:id])
            
            if room == nil
                redirect_to '/'
            end
            
            if room.player_one_id == user['id']
                room.player_count -= 1
                room.player_one_id = nil
                room.save
                flash[:success] = "You have successfully left the room!"
            elsif room.player_two_id == user['id']
                room.player_count -= 1
                room.player_two_id = nil
                room.save
                flash[:success] = "You have successfully left the room!"
            else
                flash[:danger] = "You are not in the room"
            end
            
            if room.player_one_id == nil && room.player_two_id == nil
                room.destroy
            end
            
            redirect_to '/'
        end
   
    
    def update_room
        user = session[:current_user]
        @room = Room.find(params[:id])
        
        if @room.player_one_id != user['id'] && @room.player_two_id != user['id']
            flash[:danger] = "You do not have permission to enter this part of the application."
            redirect_to '/'
        end
        
        @player_one = User.find_by_id(@room.player_one_id)
        @player_two = User.find_by_id(@room.player_two_id)
        @winner = User.find_by_id(@room.winner_id)
        
        #check for nil
        if @player_one
            @player_one_name = @player_one.username
        else
            @player_one_name = nil
        end
        
        if @player_two
            @player_two_name = @player_two.username
        else
            @player_two_name = nil
        end

        if @winner
            @winner_name = @winner.username
        else
            @winner_name = nil
        end
        
        render :json => {playerOne: @player_one_name, playerTwo: @player_two_name, winner: @winner_name }
    end
    
    def start
        user = session[:current_user]
        @room = Room.find(params[:id])
        if @room.player_one_id != user['id'] && @room.player_two_id != user['id']
            flash[:danger] = "You do not have permission to enter this part of the application."
            redirect_to '/'
        end
        
        if @room.player_one_id == nil || @room.player_two_id == nil
            flash[:danger] = "Game cannot start with less than 2 players"
            redirect_to '/'
        end
        
        room = Room.find(params[:id])
        winner_position = Random.rand(2)
        player_one = User.find(room.player_one_id)
        player_two = User.find(room.player_two_id)
        if winner_position == 0
            room.winner_id = player_one.id
            player_one.coins += room.coins_per_player
            player_one.rating += 14 #just a random rating value
            player_one.save
            
            player_two.coins -= room.coins_per_player
            player_two.rating -= 14 #again random rating
            player_two.save
        else
            room.winner_id = player_two.id
            player_two.coins += room.coins_per_player
            player_two.rating += 14
            player_two.save
            
            player_one.coins -= room.coins_per_player
            player_one.rating -= 14
            player_one.save
        end
        
        if room.winner_id == session[:current_user]['id']
            flash[:success] = "You won!"
        else
            flash[:danger] = "You lost!"
        end
        
        room.destroy
        redirect_to user_path(session[:current_user]['id'])
    end
    
    
     
    private
        def room_params
            params.require(:room).permit(:name, :coins_per_player)
        end
end
