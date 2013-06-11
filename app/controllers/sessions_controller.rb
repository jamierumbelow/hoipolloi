class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]

    session[:access_token] = auth['credentials']['token']
    session[:access_token_secret] = auth['credentials']['secret']
    session[:username] = auth['info']['nickname']

    user = User.find_or_create_by_uid :uid => auth["uid"],
                                      :nickname => auth["info"]["nickname"],
                                      :name => auth["info"]["name"],
                                      :created_at => Time.now
    session[:user_id] = user.id

    redirect_to root_url
  end

  def destroy
    session[:user_id] = session[:username] = session[:access_token] = session[:access_token_secret] = nil
    redirect_to root_url
  end
end
