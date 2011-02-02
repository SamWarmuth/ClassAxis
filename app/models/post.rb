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
    relative_time(Time.at(self.date))
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
  
  def invalidate!
    $rendered_posts[self.id] = nil
    parent = Post.get(self.parent_id)
    parent.invalidate! unless parent.nil?
  end
end

def relative_time(time)
  past = (Time.now - time) > 0
  suffix = (past ? " ago" : " from now")
  since = (Time.now - time).abs
  if since < 80.seconds
    return since.to_i.to_s + " seconds#{suffix}"
  elsif since < 1.hour
    minutes = (since/1.minute).to_i
    return "#{minutes} minute#{"s" unless minutes == 1}#{suffix}"
  elsif since < (16.hours)
    hours = (since/(1.hour)).to_i
    return "#{hours} hour#{"s" unless hours == 1}#{suffix}"
  elsif since < (5.days)
    days = (since/(1.day)).to_i + 1
    return (past ? "yesterday" : "tomorrow") if days == 1
    return "#{days} day#{"s" unless days == 1}#{suffix}"
  elsif since < (4.weeks)
    weeks = (since/(1.week)).to_i + 1
    return (past ? "last" : "next") + " week" if weeks == 1
    return "#{weeks} week#{"s" unless weeks == 1}#{suffix}"
  elsif since < (12.months)
    months = (since/(1.month)).to_i + 1
    return (past ? "last" : "next") + " month" if months == 1
    return "#{months} month#{"s" unless months == 1}#{suffix}"
  else
    years = (since/(1.year)).to_i + 1
    return (past ? "last" : "next") + " year" if years == 1
    return "#{years} year#{"s" unless years == 1}#{suffix}"
  end
end
