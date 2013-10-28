class SessionsController < ApplicationController

  # before_filter :setup_myusa_client
  # before_filter :setup_myusa_access_token

  def new
    # check for URL parameter
    # set cookie
    redirect_to '/auth/myusa'
  end


  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth['provider'], uid: auth['uid'].to_s).first ||
      User.where(provider: auth['provider'], email: auth['email']).first ||
      User.create_with_omniauth(auth)
    # Reset the session after successful login, per
    # 2.8 Session Fixation – Countermeasures:
    # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
    reset_session
    session[:user_id] = user.id
    session[:token] = auth.credentials.token
    # redirect user to application with URL parameters ?uid=1234&token=0000
    user.add_role :super_admin if User.count == 1 # make the first user an admin
    if user.email.blank?
      redirect_to edit_admin_user_path(user), :alert => "Please enter your email address."
    elsif user.has_gov_email? && user.agency.blank?
      redirect_to edit_admin_user_path(user), :alert => "Please choose your agency or parent agency from the dropdown."
    else
      redirect_to root_url, :notice => 'Signed in!'
    end

  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    message = params[:error_description] || "An unknown error has occured."
    redirect_to root_url, :alert => "Authentication error: #{message.humanize}"
  end

  # private
  # #   def setup_myusa_client
  # #     @myusa_client = OAuth2::Client.new(
  # #       ENV['MYUSA_OAUTH_PROVIDER_KEY'], ENV['MYUSA_OAUTH_PROVIDER_SECRET'], 
  # #       {:site => ENV['MYUSA_HOME'], :token_url => "/oauth/authorize"})
  # #   end

  #   def setup_myusa_access_token
  #     @myusa_access_token = OAuth2::AccessToken.new(@myusa_client, session[:token]) if session
  #   end
end
