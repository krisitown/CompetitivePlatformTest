class RoomsController < ApplicationController
    def new
        @room = Room.new
    end
    
    def create
        @room = Room.create(room_params)
        @room.player_one_id = session[:current_user]['id']
        @room.player_count = 1
        if @room.save
            flash[:success] = "You have successfully created a room!"
            redirect_to room_path(@room)
        else
            flash[:danger] = "An error occured, please try again!"
            render 'new'
        end
    end
    
    def index
        @rooms = Room.all
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
    
    def leave
        user = session[:current_user]
        room = Room.find(params[:id])
        if room.player_one_id == user['id']
            room.player_count -= 1
            room.player_one_id = nil
            room.save
            flash[:success] = "You have successfully left the room!"
            redirect_to '/'
        elsif room.player_two_id == user['id']
            room.player_count -= 1
            room.player_two_id = nil
            room.save
            flash[:success] = "You have successfully left the room!"
            redirect_to '/'
        else
            flash[:danger] = "You are not in the room"
            redirect_to '/'
        end
    end
        
        
    private
        def room_params
            params.require(:room).permit(:name, :coins_per_player)
        end
end
