class Main
  
  
  get "/" do
    redirect "/welcome" unless logged_in?
    @rooms = @user.rooms
    haml "" #loads layout.haml
  end
  get "/welcome" do
    logged_in?
    haml :welcome, :layout => false
  end

  get "/css/style.css" do
    content_type 'text/css', :charset => 'utf-8'
    sass :style
  end
  
  get "/css/jqui.css" do
    content_type 'text/css', :charset => 'utf-8'
    response['Expires'] = (Time.now + 3.years).httpdate
    sass :jqui
  end
  
  get "/settings" do
    redirect "/login" unless logged_in?
    haml :settings
  end
  
  get "/login" do
    redirect "/" if logged_in?
    haml :login, :layout => false
  end
  
  post "/login" do
    user = User.all.find{|u| u.email == params[:email].downcase}
    if user && user.valid_password?(params[:password])
      user.challenges ||= []
      user.challenges = user.challenges[0...4]
      user.challenges.unshift((Digest::SHA2.new(512) << (64.times.map{|l|('a'..'z').to_a[rand(25)]}.join)).to_s)
      user.save
      
      response.set_cookie("user", {
        :path => "/",
        :expires => Time.now + 2**20, #two weeks
        :httponly => true,
        :value => user.id
      })
      response.set_cookie("user_challenge", {
        :path => "/",
        :expires => Time.now + 2**20,
        :httponly => true,
        :value => user.challenges.first
      })
      redirect "/"
    else
      redirect "/login?error=incorrect"
    end
  end
  
  get "/logout" do
    response.set_cookie("user", {
      :path => "/",
      :expires => Time.now + 2**20,
      :httponly => true,
      :value => ""
    })
    response.set_cookie("user_challenge", {
      :path => "/",
      :expires => Time.now + 2**20,
      :httponly => true,
      :value => ""
    })
    redirect "/login"
  end

  get "/signup" do
    redirect "/" if logged_in?
    haml :signup, :layout => false
  end
  
  post "/signup" do
    redirect "/signup?error=email" unless User.all.find{|u| u.email == params[:email].downcase}.nil?
    redirect "/signup?error=password" unless params[:password] == params[:password2]
    redirect "/signup?error=empty" if params[:name].empty? || params[:email].empty? || params[:password].empty?
    
    user = User.new
    user.name = params[:name]
    user.email = params[:email].downcase
    user.set_password(params[:password])
    user.permalink = generate_permalink(user, user.name)
    user.broadcast_ids = Broadcast.all.find_all{|b| b.announce_to_new_users == true}.map(&:id)
    user.save
    
    user.challenges ||= []
    user.challenges = user.challenges[0...4]
    user.challenges.unshift((Digest::SHA2.new(512) << (64.times.map{|l|('a'..'z').to_a[rand(25)]}.join)).to_s)
    user.save
    
    response.set_cookie("user", {
      :path => "/",
      :expires => Time.now + 2**20, #two weeks
      :httponly => true,
      :value => user.id
    })
    response.set_cookie("user_challenge", {
      :path => "/",
      :expires => Time.now + 2**20,
      :httponly => true,
      :value => user.challenges.first
    })
    redirect "/"
  end
  
  ## AJAX routes
  
  post "/ajax/hide-broadcast/:broadcast_id" do
    return 403 unless logged_in? #forbidden
    broadcast = Broadcast.get(params[:broadcast_id])
    return 404 if broadcast.nil? #not found
    @user.broadcast_ids.delete(broadcast.id)
    @user.save
    return 200 #success
  end
  
  
  get "/ui/message/:id" do
    redirect "/login" unless logged_in?
    @message = Message.get(params[:id])
    return 404 if @message.nil?
    
    haml :message, :layout => false
  end
  


  get "/ui/room/:room_id" do
    redirect "/login" unless logged_in?
    @room = Room.get(params[:room_id])
    return "Room not found." if @room.nil?
    @messages = @room.messages
    haml :conversation, :layout => false
  end
  
  post "/ui/join-room/:room_id" do
    redirect "/login" unless logged_in?
    @room = Room.get(params[:room_id])
    return "Room not found." if @room.nil?
    @user.room_ids << @room.id unless @user.room_ids.include?(@room.id)
    @user.save
    haml :room_row, :layout => false
  end
  
  post "/ui/create-room/" do
    redirect "/login" unless logged_in?
    @room = Room.new
    @room.name = params[:name]
    @room.set_permalink
    @room.save
    params[:ids].split(" ").each do |id|
      user = User.get(id)
      next if user.nil?
      user.room_ids << @room.id
      user.save
    end
    message = Message.new
    message.content = "Room created."
    message.sender_id = @user.id
    message.room_id = @room.id
    message.save
    @user.room_ids << @room.id
    @user.save
    haml :room_row, :layout => false
  end

  
  post "/ui/message/:room_id/" do
    return 403 unless logged_in?
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    
    @message = Message.new
    @message.sender_id = @user.id
    @message.room_id = @room.id
    @message.content = params[:content]
    @message.save
    
    @force_blue = true
    pusher_message = haml :message, :layout => false
    Thread.new{Pusher[@room.id].trigger('addMessage', {:content => pusher_message, :user_id => @user.id})}
    @force_blue = false
    Thread.new{Pusher["new_messages"].trigger('newMessage', {:room => @room.id})}
    
    return {:content => (haml :message, :layout => false), :container => ".conversation-container"}.to_json
  end
  
  post "/message/addfile/:room_id" do
    return 403 unless logged_in?
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    
    file = Upload.new
    file.name = params[:qqfile].gsub(" ", "")
    extension = file.name.split(".").last
    file.file_type = extension
    file.save
    file.url = "/uploads/#{@user.id}/files/#{file.id}.#{extension}"
    file.file_path = "public/uploads/#{@user.id}/files/#{file.id}.#{extension}"
    
    FileUtils.mkdir_p "public/uploads/#{@user.id}/files/"
    data = request.env['rack.input']
    File.open(file.file_path, 'w') {|f| f.write(data.read)}    
    file.save
    
    
    @user.file_ids ||= []
    @user.file_ids << file.id
    @user.save
    

    
    @message = Message.new
    @message.sender_id = @user.id
    @message.room_id = @room.id
    @message.upload_id = file.id
    @message.save
    
    
    pusher_message = haml :message, :layout => false
    Thread.new{Pusher[@room.id].trigger('addMessage', {:content => pusher_message, :user_id => false})}

    return '{"success":true}'
  end

end