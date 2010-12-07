class Main
  
  
  get "/" do
    redirect "/welcome" unless logged_in?
    haml :index
  end
  get "/welcome" do
    logged_in?
    haml :welcome, :layout => false
  end
  get "/groups" do
    redirect "/login" unless logged_in?
    haml :groups
  end
  get "/group/:permalink" do
    redirect "/" unless logged_in?
    @course = Group.by_permalink(:key => params[:permalink]).first
    haml :course
  end
  
  get "/group/:permalink/join" do
    redirect "/login" unless logged_in?
    @group = Group.by_permalink(:key => params[:permalink]).first
    redirect "/group/#{params[:permalink]}" if @group.user_ids.include?(@user.id)
    @group.user_ids << @user.id
    @group.save
    redirect "/group/#{params[:permalink]}"
  end
  
  get "/edit-group" do
    redirect "/login" unless logged_in?
    haml :edit_group
  end
  
  post "/edit-group" do
    redirect "/login" unless logged_in?
    return "Need a name!" if params[:name].empty?
    if params[:group_id]
      group = Group.get(params[:group_id])
      return "error!" if group.nil?
    else
      group = Group.new
    end
    group.name = params[:name]
    group.abbreviation = params[:abbreviation] unless params[:abbreviation].empty?
    group.is_public = params[:public]
    group.user_ids << @user.id
    group.admin_id = @user.id
    group.calendar_id ||= Calendar.create(:name => group.name).id
    group.permalink ||= generate_permalink(group, group.name)
    group.save
    redirect "/group/"+group.permalink
  end
  
  
  get "/courses" do
    redirect "/login" unless logged_in?
    haml :courses
  end

  
  get "/course/:permalink" do
    redirect "/login" unless logged_in?
    @course = Group.by_permalink(:key => params[:permalink]).first
    haml :course
  end
  
  get "/course/:permalink/join" do
    redirect "/login" unless logged_in?
    @course = Group.by_permalink(:key => params[:permalink]).first
    unless @course.user_ids.include?(@user.id)
      @course.user_ids << @user.id
      @course.save
    end
    redirect "/course/#{params[:permalink]}"
  end

  get "/edit-course" do
    redirect "/login" unless logged_in?
    haml :edit_course
  end
  
  post "/edit-course" do
    redirect "/login" unless logged_in?
    if params[:course_id]
      course = Group.get(params[:course_id])
      return "error!" if course.nil?
    else
      course = Group.new
    end
    course.name = params[:name]
    course.course_number = params[:course_number]
    course.is_public = params[:public]
    course.user_ids << @user.id
    course.admin_id = @user.id
    course.calendar_id ||= Calendar.create(:name => course.name).id
    course.permalink ||= generate_permalink(course, course.name)
    course.save
    redirect "/course/"+course.permalink
  end
  
  get "/events" do
    redirect "/login" unless logged_in?
    haml :events
  end
  
  get "/event/:permalink" do
    redirect "/login" unless logged_in?
    @event = Event.by_permalink(:key => params[:permalink]).first
    
    haml :event
  end
  
  get "/event/:permalink/attend" do
    redirect "/login" unless logged_in?
    @event = Event.by_permalink(:key => params[:permalink]).first
    unless @event.attendee_ids.include?(@user.id)
      @event.attendee_ids << @user.id
      @event.save
    end
    redirect "/event/#{@event.permalink}"
  end

  get "/messages" do
    redirect "/login" unless logged_in?
    haml :messages
  end
  
  get "/new-event" do
    redirect "/login" unless logged_in?
    haml :new_event
  end
  
  post "/new-event" do
    redirect "/login" unless logged_in?
    event = Event.new
    calendar = Calendar.get(params[:calendar_id])
    redirect "/404" if calendar.nil?
    #error check.
    event.name = params[:name]
    event.tags = params[:tags].split(" ")
    event.location = params[:location]
    event.date = Time.parse(params[:date] + " " + params[:time]).to_i
    event.description = params[:description]
    event.attendee_ids << @user.id
    event.save
    calendar.event_ids << event.id
    calendar.save
    redirect "/event/#{event.permalink}"
  end
  
  
  get "/discussions" do
    redirect "/login" unless logged_in?
    haml :discussions
  end
  
  get "/discussion/:permalink" do
    redirect "/login" unless logged_in?
    @topic = Topic.by_permalink(:key => params[:permalink]).first
    redirect "/404" if @topic.nil?
    haml :discussion
  end
  
  get "/new-discussion" do
    redirect "/login" unless logged_in?
    haml :new_discussion
  end
  
  post "/new-discussion" do
    redirect "/login" unless logged_in?
    topic = Topic.new
    topic.title = params[:title]
    topic.tags = params[:tags].split(" ")
    topic.content = params[:content]
    topic.permalink = generate_permalink(topic, topic.title)
    topic.creator_id = @user.id
    topic.save
    redirect "/discussion/#{topic.permalink}"
  end
  
  get "/reply/:id" do
    redirect "/login" unless logged_in?
    @parent = Post.get(params[:id])
    @parent = Topic.get(params[:id]) if @parent['couchrest-type'] == "Topic"
    redirect "/404" if @parent.nil?
    
    haml :reply
  end
  
  post "/reply/:id" do
    redirect "/login" unless logged_in?
    @parent = Post.get(params[:id])
    @parent = Topic.get(params[:id]) if @parent['couchrest-type'] == "Topic"
    redirect "/404" if @parent.nil?
    
    post = Post.new
    post.content = params[:content].gsub(/[\r]?\n/, '<br/>')
    post.parent_id = @parent.id
    post.topic_id = @parent.topic.id
    post.creator_id = @user.id
    post.save
    post.permalink = generate_permalink(post, post.id)
    post.save
    
    redirect "/discussion/#{@parent.topic.permalink}"
  end
  
  get "/post/:permalink" do
    redirect "/login" unless logged_in?
    @post = Post.by_permalink(:key => params[:permalink]).first
    redirect "/404" if @post.nil?
    haml :posts
  end
  
  get "/user/:permalink" do
    redirect "/login" unless logged_in?
    @selected_user = User.by_permalink(:key => params[:permalink]).first
    haml :user
  end
  
  post "/new-message" do
    redirect "/login" unless logged_in?
    @selected_user = User.all.find{|u| u.name == params[:name]}
    redirect "/?error=notfound" if @selected_user.nil?
    message = Message.new
    message.sender_id = @user.id
    message.receiver_id = @selected_user.id
    message.subject = params[:subject]
    message.content = params[:message]
    message.save
    redirect "/" #this should eventually be an ajax call.
  end
  
  get "/css/style.css" do
    content_type 'text/css', :charset => 'utf-8'
    response['Expires'] = (Time.now + 3.years).httpdate
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
  
  get "/search" do
    redirect "/login" unless logged_in?
    search = params[:search].downcase
    @posts = Post.all.find_all{|p| p.content.downcase.include?(search)}
    @topics = Topic.all.find_all{|t| t.title.downcase.include?(search) || t.content.downcase.include?(search)}
    @events = Event.all.find_all{|e| e.name.downcase.include?(search) || e.description.to_s.downcase.include?(search)}
    @users = User.all.find_all{|u| u.name.downcase.include?(search)}
    @groups = Group.all.find_all{|g| g.course_number.nil? && g.name.downcase.include?(search)}
    @courses = Group.all.find_all{|g| !g.course_number.nil? && g.name.downcase.include?(search)}
    
    @result_count = @posts.count + @events.count + @users.count + @topics.count + @courses.count + @groups.count
    haml :search
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
    redirect "/signup?error=empty" if !params[:name].empty? && !params[:email].empty? && !params[:password].empty?
    
    user = User.new
    user.name = params[:name]
    user.email = params[:email].downcase
    user.set_password(params[:password])
    user.calendar_id = Calendar.create(:name => user.name).id
    user.permalink = generate_permalink(user, user.name)
    user.save
    redirect "/login?success=created"
  end
  
  get "/stats" do
    redirect "/" unless logged_in?
    haml :stats, :layout => false
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
  
  post "/ajax/add-post" do
    return 403 unless logged_in? #forbidden
    @parent = Post.get(params[:parent_id])
    @parent = Topic.get(params[:parent_id]) if @parent['couchrest-type'] == "Topic"
    return 404 if @parent.nil? #not found
    @topic = @parent.topic
    
    @post = Post.new
    @post.content = params[:content].gsub(/[\r]?\n/, '<br/>')
    @post.parent_id = @parent.id
    @post.topic_id = @topic.id
    @post.creator_id = @user.id
    @post.save
    @post.permalink = generate_permalink(@post, @post.id)
    @post.save
    content = haml :post, :layout => false
    Thread.new{Pusher[@topic.id].trigger('addPost', {:parentID => @parent.id, :content => content})}
    
    return 200
  end
  

end