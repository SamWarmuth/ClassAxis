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
    return $style ||= (sass :style) if CACHE_CSS
    
    return sass :style
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
  
  get "/room/:room_permalink" do
    logged_in?
    if @user.nil?
      @room = Room.by_permalink(:key => params[:room_permalink]).first
      return '404' if @room.nil?
      @user = User.new
      @user.challenges ||= []
      @user.challenges = @user.challenges[0...4]
      @user.challenges.unshift((Digest::SHA2.new(512) << (64.times.map{|l|('a'..'z').to_a[rand(25)]}.join)).to_s)
      @user.room_ids << @room.id
      @user.save
      



      response.set_cookie("user", {
        :path => "/",
        :expires => Time.now + 2**20, #two weeks
        :httponly => true,
        :value => @user.id
      })
      response.set_cookie("user_challenge", {
        :path => "/",
        :expires => Time.now + 2**20,
        :httponly => true,
        :value => @user.challenges.first
      })
      
       
      @rooms = [@room]
      haml "" #run normal layout.haml
    else
      #user exists, just put them there somehow.
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
    
    user.room_ids << Room.by_permalink(:key => "thelobby").first.id
    user.save
    
    redirect "/"
  end
  
  ## AJAX routes
  
  
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
    from = nil
    $rooms_users.each_pair do |key,v|
      if v.include?(@user.id)
        from = key 
        v.delete(@user.id)
      end
    end
    $rooms_users[@room.id] ||= []
    $rooms_users[@room.id] << @user.id
    
    from_count = from ? $rooms_users[from].count : 0
    to_count = $rooms_users[@room.id].count
    Thread.new{Pusher["updates"].trigger('userMove', {:from => from, :to => @room.id, :fcount => from_count, :tcount => to_count})}
    
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
  post "/ui/leave-room/:room_id" do
    redirect "/login" unless logged_in?
    @room = Room.get(params[:room_id])
    return "Room not found." if @room.nil?
    @user.room_ids.delete(@room.id)
    @user.save
    haml :room_row, :layout => false
  end
  
  post "/ui/create-room/" do
    redirect "/login" unless logged_in?
    @room = Room.new
    @room.name = params[:name]
    @room.is_public = params[:public] == 'true'
    @room.set_permalink
    @room.admin_id = @user.id
    
    message = Message.new
    message.content = "Room created."
    message.sender_id = @user.id
    message.save
    
    @room.message_ids << message.id
    @room.save
    params[:ids].split(" ").each do |id|
      user = User.get(id)
      next if user.nil?
      user.room_ids << @room.id
      user.save
    end

    
    @user.room_ids << @room.id
    @user.save
    haml :room_row, :layout => false
  end
  
  post "/ui/message/:room_id/" do
    return 403 unless logged_in?
    return 403 if params[:content].empty?
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    @message = Message.new
    @message.sender_id = @user.id
    @message.content = params[:content]
    @message.save
    @room.message_ids << @message.id
    @room.save
    
    @message_id = @message.id
    pusher_message = haml :message, :layout => false
    Thread.new{Pusher[@room.id].trigger('addMessage', {:content => pusher_message, :user_id => @user.id})}
    Thread.new{Pusher["updates"].trigger('newMessage', {:room => @room.id})}
    return {:content => pusher_message, :container => ".conversation-container"}.to_json
  end
  
  get "/ui/file-list/:room_id" do
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    
    @files = @room.file_ids.map{|f| Upload.get(f)}
    haml :files, :layout => false
  end
  
  get "/ui/settings/:room_id" do
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    
    haml :settings, :layout => false
  end
  
  get "/ui/user-list/:room_id" do
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    
    haml :user_list, :layout => false
  end
  
  get "/ui/browse-rooms" do
    return "Not logged in." unless logged_in?
    haml :browse_rooms, :layout => false
  end
  
  post "/message/addfile/:room_id" do
    return 403 unless logged_in?
    @room = Room.get(params[:room_id])
    return 404 if @room.nil?
    return 403 if @user.file_ids.length >= @user.max_file_count
    puts "-=-" + params.inspect + " -=-"
    
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
    file.file_size = File.size(file.file_path)    
    file.save
    
    
    @user.file_ids ||= []
    @user.file_ids << file.id
    @user.save
    
    @room.file_ids ||= []
    @room.file_ids << file.id
    
    @message = Message.new
    @message.sender_id = @user.id
    @message.upload_id = file.id
    @message.save
    @room.message_ids << @message.id
    @room.save
    
    
    @message_id = @message.id
    pusher_message = haml :message, :layout => false
    Thread.new{Pusher[@room.id].trigger('addMessage', {:content => pusher_message, :user_id => false})}

    return '{"success":true}'
  end
  get "/ui/heartbeat" do
    return 403 unless logged_in? #this updates their logged in time.
    return 200
  end
end