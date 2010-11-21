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
    redirect "/course/#{params[:permalink]}" if @course.user_ids.include?(@user.id)
    @course.user_ids << @user.id
    @course.save
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
  
  get "/new-event" do
    redirect "/login" unless logged_in?
    haml :new_event
  end
  
  
  get "/discussions" do
    redirect "/login" unless logged_in?
    haml :discussions
  end
  
  get "/new-discussion" do
    redirect "/login" unless logged_in?
    haml :new_discussion
  end
  

  
  get "/topics/autogenerate" do
    topic = Topic.new
    topic.title = random_question
    topic.content = random_question
    topic.save
    rand(5).times do
      post = Post.new
      post.parent_id = topic.id
      post.content = random_answer
      post.save
    end
    redirect "/topics"
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
  
  get "/login" do
    logged_in?
    redirect "/" if @user
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
      redirect "/login?error=incorrect" #TODO show an error
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

end
