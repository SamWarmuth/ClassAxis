class Main
  get "/" do
    logged_in?
    haml :index
  end
  get "/groups" do
    logged_in?
    haml :groups
  end
  get "/group/:permalink" do
    logged_in?
    @course = Group.all.find{|c| c.permalink == params[:permalink]}
    haml :course
  end
  
  
  get "/courses" do
    logged_in?
    haml :courses
  end
  get "/edit-course" do
    logged_in?
    haml :edit_course
  end
  
  
  get "/discussions" do
    logged_in?
    haml :discussions
  end
  
  get "/course/:permalink" do
    logged_in?
    @course = Group.all.find{|c| c.permalink == params[:permalink]}
    haml :course
  end
  
  get "/edit-course" do
    logged_in?
    haml :edit_course
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
    logged_in?
    @selected_user = User.all.find{|u| u.permalink == params[:permalink]}
    haml :user
  end
  
  get "/css/style.css" do
    content_type 'text/css', :charset => 'utf-8'
    sass :style
  end
  
  get "/css/jqui.css" do
    content_type 'text/css', :charset => 'utf-8'
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
