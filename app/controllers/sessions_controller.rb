class SessionsController < ApplicationController
    def new
    end
    
    def create
        user = User.find_by(username: params[:username].downcase)
        if user && user.authenticate(params[:password])
            flash[:success] = "You have successfully logged in!"
            session[:current_user] = user
            redirect_to '/'
        else
            flash[:danger] = "Incorrect username/password!"
            redirect_to '/login'
        end
    end
    
    def destroy
        session[:current_user] = nil
        redirect_to '/'
    end 

end
