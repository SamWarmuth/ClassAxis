class Main
  get "/" do
    haml :index
  end
  get "/groups" do
    haml :groups
  end
end
