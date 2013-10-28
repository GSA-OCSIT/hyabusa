require 'spec_helper'

describe "Base API" do
  it 'retrieves meta information about the API' do
    get "/api/index.html"
    expect(response).to be_success
    # TODO: swagger implementation
  end

  describe "GET /api/profiles" do
  	context "when requesting profiles" do
  		before do
  			@valid_token = "good_token"
  			@invalid_token = "bad_token"
  			@oauth_params = {
  					'provider' => 'myusa',
  					'uid' => '4dd1',
  					'info' => {
  						'email' => "citizen.kane@gmail.com"
  					}
  				}

  			@myusa_user = User.create_with_omniauth(@oauth_params)
  		end

  		context "when an unauthorized request is made" do
  			it "should return an error" do
  				stub_request(:get, "#{ENV['MYUSA_HOME']}/api/verify_credentials?")
  					.with(:headers => { 'HTTP_AUTHORIZATION' => "Bearer #{@invalid_token}"})
  					.to_return(:status => 401, :body => 'Unauthorized')
  				get "/api/profiles", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@invalid_token}"}
  				# expect(response).to raise_error
  				# expect(response).to raise_errorf
  				expect(response).to eq("Unauthorized")
  			end
  		end

  		context "when an authorized request is made" do
  			it "should return status 200" do
  				stub_request(:get, "#{ENV['MYUSA_HOME']}/api/verify_credentials?")
  					.with(:headers => {'HTTP_AUTHORIZATION'=>"Bearer #{@valid_token}"})
  					.to_return(:status => 200, :body => "4dd1", :headers => {})         		
  				get "/api/profiles", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@valid_token}"}
  				expect(response).to eq('4dd1')
  			end

  			it "should return no profile" do
	  			@myusa_user.profile.should be_nil
	  		end

	  		context "when a has a profile" do
	  			before do
	  				@profile = Profile.new(
		  					:org_type => "Service Provider",
		  					:company_name => "Kane's Canes",
		  					:user => @myusa_user,
		  					:state => 'CA',
		  					:address1 => '123 Park Ave'
	  					)
	  				@profile.user = @myusa_user
	  				@profile.save
	  				@myusa_user = User.find_by_uid('4dd1')
	  			end

	  			it "should return the user's profile" do
	  				@myusa_user.profile.should_not be_nil
	  			end
	  		end
  		end
  	end
  end
end

# 

# require 'spec_helper'

# describe "Apis" do
#   before do
#     create_confirmed_user_with_profile

#     @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
#     @app.oauth_scopes = OauthScope.all
#     authorization = OAuth2::Model::Authorization.new
#     authorization.scope = @app.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
#     authorization.client = @app.oauth2_client
#     authorization.owner = @user
#     access_token = authorization.generate_access_token
#     client = OAuth2::Client.new(@app.oauth2_client.client_id, @app.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
#     @token = OAuth2::AccessToken.new(client, access_token)
#   end

#   describe "GET /api/profile" do
#     context "when the request has a valid token" do
#       context "when the user queried exists" do
#         it "should return JSON with a user profile with email and unique ID" do
#           get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           response.code.should == "200"
#           parsed_json = JSON.parse(response.body)
#           parsed_json.should_not be_nil
#           parsed_json["email"].should == 'joe@citizen.org'
#           parsed_json["id"].should_not be_nil
#           parsed_json.reject{|k,v| k == "email" or k == "id" or k == "uid"}.each do |key, value|
#             parsed_json[key].should be_nil
#           end
#         end

#         it "should log the profile request" do
#           get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           log = AppActivityLog.find(:all, :order => :created_at).last
#           log.action.should == "show"
#           log.controller.should == "profiles"
#           log.app.name.should == "App1"
#           log.user.email.should == "joe@citizen.org"
#         end

#         context "when the schema parameter is set" do
#           it "should render the response in a Schema.org hash" do
#             get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#             response.code.should == "200"
#             parsed_json = JSON.parse(response.body)
#             parsed_json.should_not be_nil
#             parsed_json["email"].should == 'joe@citizen.org'
#           end
#         end
#       end
#     end
    
#     context "when the request does not have a valid token" do
#       it "should return an error message" do
#         get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to read that user's profile."
#       end
#     end
#   end
  
#   describe "POST /api/notifications" do
#     before do
#       create_approved_beta_signup('jane@citizen.org')
#       @other_user = User.create!(:email => 'jane@citizen.org', :password => 'Password1')
#       @other_user.profile = Profile.new(:first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
#       @app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
#       @app2.oauth_scopes << OauthScope.all
#       login(@user)
#       1.upto(14) do |index|
#         @notification = Notification.create!({:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id}, :as => :admin)
#       end
#       @other_user_notification = Notification.create!({:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id}, :as => :admin)
#       @other_app_notification = Notification.create!({:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id}, :as => :admin)
#       @user.notifications.each{ |n| n.destroy(:force) }
#       @user.notifications.reload
#     end
    
#     context "when the user has a valid token" do    
#       context "when the notification attributes are valid" do
#         it "should create a new notification when the notification info is valid" do
#           @user.notifications.size.should == 0
#           post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           response.code.should == "200"
#           @user.notifications.reload
#           @user.notifications.size.should == 1
#           @user.notifications.first.subject.should == "Project MyUSA"
#         end
#       end
      
#       context "when the notification attributes are not valid" do
#         it "should return an error message" do
#           post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           response.code.should == "400"
#           parsed_response = JSON.parse(response.body)
#           parsed_response["message"]["subject"].should == ["can't be blank"]
#         end
#       end
#     end
    
#     context "when the the app does not have the proper scope" do
#       before do
#         @app3 = App.create(:name => 'App3', :redirect_uri => "http://localhost/")
#         @app3.oauth_scopes = OauthScope.all
#         authorization = OAuth2::Model::Authorization.new
#         authorization.scope = "tasks" # this is the wrong scope for notifications
#         authorization.client = @app3.oauth2_client
#         authorization.owner = @user
#         access_token = authorization.generate_access_token
#         client = OAuth2::Client.new(@app3.oauth2_client.client_id, @app3.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
#         @token3 = OAuth2::AccessToken.new(client, access_token)
#       end
      
#       it "should return an error message" do
#         post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token3.token}"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to notifications for that user."
#       end
#     end

#     context "when the user has an invalid token" do
#       it "should return an error message" do
#         post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
#         response.code.should == "403"
#         parsed_response = JSON.parse(response.body)
#         parsed_response["message"].should == "You do not have access to send notifications to that user."
#       end
#     end
#   end

#   describe "GET /api/tasks.json" do
#     context "when token is valid" do
#       context "when there are notifications for a user, some of which were created by the app making the request" do
#         before do
#           @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
#           @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1}, :as => :admin)
#         end
      
#         it "should return the tasks that were created by the calling app" do
#           get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}" }
#           response.code.should == "200"
#           parsed_json = JSON.parse(response.body)
#           parsed_json.size.should == 1
#           parsed_json.first["name"].should == "Task #1"
#         end
#       end
#     end
    
#     context "when the the app does not have the proper scope" do
#       before do
#         @app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
#         @app4.oauth_scopes = OauthScope.all
#         authorization = OAuth2::Model::Authorization.new
#         authorization.scope = "notifications"
#         authorization.client = @app4.oauth2_client
#         authorization.owner = @user
#         access_token = authorization.generate_access_token
#         client = OAuth2::Client.new(@app4.oauth2_client.client_id, @app4.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
#         @token4 = OAuth2::AccessToken.new(client, access_token)
#       end
      
#       it "should return an error message" do
#         get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token4.token}"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to tasks for that user."
#       end
#     end
    
#     context "when the request does not have a valid token" do
#       it "should return an error message" do
#         get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to view tasks for that user."
#       end
#     end
#   end
  
#   describe "POST /api/tasks" do
#     context "when the caller has a valid token" do
#       context "when the appropriate parameters are specified" do
#         it "should create a new task for the user" do
#           post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           response.code.should == "200"
#           parsed_json = JSON.parse(response.body)
#           parsed_json.should_not be_nil
#           parsed_json["name"].should == "New Task"
#           Task.find_all_by_name_and_user_id_and_app_id('New Task', @user.id, @app.id).should_not be_nil
#         end
#       end
      
#       context "when the required parameters are missing" do
#         it "should return an error message" do
#           post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#           response.code.should == "400"
#           parsed_json = JSON.parse(response.body)
#           parsed_json["message"].should == {"name"=>["can't be blank"]}
#         end
#       end
#     end
    
#     context "when the request does not have a valid token" do
#       it "should return an error message" do
#         post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to create tasks for that user."
#       end
#     end
#   end
  
#   describe "GET /api/tasks/:id.json" do
#     before {@task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id}, :as => :admin)}
    
#     context "when the token is valid" do
#       it "should retrieve the task" do
#         get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
#         response.code.should == "200"
#         parsed_json = JSON.parse(response.body)
#         parsed_json.should_not be_nil
#         parsed_json["name"].should == "New Task"
#       end
#     end
    
#     context "when the request does not have a valid token" do
#       it "should return an error message" do
#         get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
#         response.code.should == "403"
#         parsed_json = JSON.parse(response.body)
#         parsed_json["message"].should == "You do not have access to view tasks for that user."
#       end
#     end
#   end
# end
