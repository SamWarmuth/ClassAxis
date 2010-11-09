class Main
  get "/" do
    haml :index
  end
  get "/groups" do
    haml :groups
  end
  get "/topics" do
    haml :topics
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
end
