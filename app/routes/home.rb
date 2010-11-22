class Main
  get "/" do
    redirect "/login" unless logged_in?
    haml :index
    
  end
  get "/groups" do
    redirect "/login" unless logged_in?
    haml :groups
  end
  get "/group/:permalink" do
    redirect "/" unless logged_in?
    @course = Group.all.find{|c| c.permalink == params[:permalink]}
    haml :course
  end
  
  get "/group/:permalink/join" do
    redirect "/login" unless logged_in?
    @group = Group.all.find{|c| c.permalink == params[:permalink]}
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
    if params[:group_id]
      group = Group.find(params[:group_id])
      return "error!" if group.nil?
    else
      group = Group.new
    end
    group.name = params[:name]
    group.abbreviation = params[:abbreviation] unless params[:abbreviation].empty?
    group.is_public = params[:public]
    group.user_ids << @user.id
    group.admin_id = @user.id
    group.save
    redirect "/group/"+group.permalink
  end
  
  
  get "/courses" do
    redirect "/login" unless logged_in?
    haml :courses
  end

  
  get "/course/:permalink" do
    redirect "/login" unless logged_in?
    @course = Group.all.find{|c| c.permalink == params[:permalink]}
    haml :course
  end
  
  get "/course/:permalink/join" do
    redirect "/login" unless logged_in?
    @course = Group.all.find{|c| c.permalink == params[:permalink]}
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
      course = Group.find(params[:course_id])
      return "error!" if course.nil?
    else
      course = Group.new
    end
    course.name = params[:name]
    course.course_number = params[:course_number]
    course.is_public = params[:public]
    course.user_ids << @user.id
    course.admin_id = @user.id
    course.save
    redirect "/course/"+course.permalink
  end
  
  get "/events" do
    redirect "/login" unless logged_in?
    haml :events
  end
  
  get "/event/:permalink" do
    redirect "/login" unless logged_in?
    @event = Event.all.find{|e| e.permalink == params[:permalink]}
    haml :event
  end
  
  get "/event/:permalink/attend" do
    redirect "/login" unless logged_in?
    @event = Event.all.find{|e| e.permalink == params[:permalink]}
    unless @event.attendee_ids.include?(@user.id)
      @event.attendee_ids << @user.id
      @event.save
    end
    redirect "/event/#{@event.permalink}"
  end
  
  get "/new-event" do
    redirect "/login" unless logged_in?
    haml :new_event
  end
  
  post "/new-event" do
    redirect "/login" unless logged_in?
    event = Event.new
    event.name = params[:name]
    event.tags = params[:tags].split(" ")
    event.location = params[:location]
    event.date = Time.parse(params[:date] + " " + params[:time]).to_s 
    event.description = params[:description]
    event.attendee_ids << @user.id
    event.save
    redirect "/event/#{event.permalink}"
  end
  
  
  get "/discussions" do
    redirect "/login" unless logged_in?
    haml :discussions
  end
  
  get "/discussion/:permalink" do
    redirect "/login" unless logged_in?
    @topic = Topic.all.find{|t| t.permalink == params[:permalink]}
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
    puts @parent.content
    
    post = Post.new
    post.content = params[:content]
    post.parent_id = @parent.id
    post.topic_id = @parent.topic.id
    post.creator_id = @user.id
    post.save
    post.save #...yeah. Two. Permalinks need work.
    
    redirect "/discussion/#{@parent.topic.permalink}"
  end
  
  get "/user/:permalink" do
    redirect "/login" unless logged_in?
    @selected_user = User.all.find{|u| u.permalink == params[:permalink]}
    haml :user
  end
  
  get "/css/style.css" do
    content_type 'text/css', :charset => 'utf-8'
    response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
    sass :style
  end
  
  get "/css/jqui.css" do
    content_type 'text/css', :charset => 'utf-8'
    response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
    sass :jqui
  end
  
  get "/favicon.ico" do
    return ""
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
      user.challenges << (Digest::SHA2.new(512) << (64.times.map{|l|('a'..'z').to_a[rand(25)]}.join)).to_s
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
        :value => user.challenges.last
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
    perma = generate_permalink(params[:name])
    redirect "/signup?error=name" unless User.all.find{|u| u.permalink == perma}.nil?
    redirect "/signup?error=password" unless params[:password] == params[:password2]
    if !params[:name].empty? && !params[:email].empty? && !params[:password].empty?
      user = User.new
      user.name = params[:name]
      user.email = params[:email]
      user.set_password(params[:password])
      user.save
      redirect "/login?success=created"
    else
      redirect "/signup?error=empty"
    end
  end
end
