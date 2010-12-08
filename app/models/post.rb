class Post < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :creator_id
  view_by :creator_id
  
  property :parent_id
  property :topic_id
  
  property :date, :default => Proc.new{Time.now.to_i}
  view_by :date
  
  property :content
  property :permalink
  view_by :permalink
  
  view_by :topic_id
  view_by :parent_id

  def creator
    User.get(self.creator_id)
  end
  def children
    Post.by_parent_id(:key => self.id).sort_by{|p| p.date}.reverse
  end
  
  def time_since
    fuzzy_time_since(Time.at(self.date))
  end
  
  def depth
    deep = 0
    parent = self
    while parent['couchrest-type'] == "Post"
      parent = Post.get(parent.parent_id)
      deep += 1
    end
    return deep
  end
  
  def topic
    Topic.get(self.topic_id)
  end
  
  def self.newest(count)
    self.by_date(:endkey => Time.now.to_i).reverse[0...count]
  end
end

def fuzzy_time_since(time)
  since = Time.now - time
  if since < 80.seconds
    return since.to_i.to_s + " seconds ago"
  elsif since < 1.hour
    minutes = (since/1.minute).to_i
    return "#{minutes} minute#{"s" unless minutes == 1} ago"
  elsif since < (16.hours)
    hours = (since/(1.hour)).to_i
    return "#{hours} hour#{"s" unless hours == 1} ago"
  elsif since < (5.days)
    days = (since/(1.day)).to_i + 1
    return "yesterday" if days == 1
    return "#{days} day#{"s" unless days == 1} ago"
  else
    return time.strftime("on %b %d %l:%M%p")
  end
end