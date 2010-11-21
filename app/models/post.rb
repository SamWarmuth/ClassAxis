class Post < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :creator_id
  property :parent_id
  property :topic_id
  
  property :date, :default => Time.now.to_s
  
  property :content
  property :permalink

  def creator
    User.get(self.creator_id)
  end
  def children
    Post.all.find_all{|p| p.parent_id == self.id}
  end
  
  def time_since
    fuzzy_time_since(Time.parse(self.date))
  end
  
  save_callback :before, :set_permalink
  
  def set_permalink
    self.permalink = generate_permalink(self.id)
  end
  
  def topic
    Topic.get(self.topic_id)
  end

end

def fuzzy_time_since(time)
  since = Time.now - time
  if since < 180
    return since.to_i.to_s + " seconds ago"
  elsif since < 60*60
    minutes = (since/60).to_i
    return "#{minutes} minute#{"s" unless minutes == 1} ago"
  elsif since < (60*60*12)
    hours = (since/(60*60)).to_i
    
    return "#{hours} hour#{"s" unless hours == 1} ago"
  else
    return Time.parse(self.date).to_s
  end
end