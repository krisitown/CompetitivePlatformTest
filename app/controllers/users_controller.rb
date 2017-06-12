class UsersController < ApplicationController
    def new
        @user = User.new 
    end
    
    def create
        @user = User.new(user_params)
        @user.coins = 0
        @user.rating = 1200 #default rating
        if @user.save 
            flash[:success] = "Successfully created an account!"
            session[:current_user] = @user
            redirect_to user_path(@user)
        else
            flash[:danger] = "An error has occured, please try again!"
            render 'new'
        end
    end
    
    def show
        @user = User.find(params[:id])
    end
    
    private
        def user_params
            params.require(:user).permit(:username, :password, :password_confimarion)
        end
        
end
