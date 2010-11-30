class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :email
  property :permalink
  property :date, :default => Proc.new{Time.now.to_i}
  property :calendar_id
  
  property :is_admin, :default => false
  property :broadcast_ids, :default => []
  
  property :picture_url
  
  def groups
    Group.all.find_all{|g| g.course_number.nil? && g.user_ids.include?(self.id)}.sort_by{|c| c.name}
  end
  def courses
    Group.all.find_all{|g| !g.course_number.nil? && g.user_ids.include?(self.id)}.sort_by{|c| c.name}
  end
  def messages
    Message.all.find_all{|m| m.receiver_id == self.id}.sort_by{|m| m.date}
  end
  def sent_messages
    Message.all.find_all{|m| m.sender_id == self.id}.sort_by{|m| m.date}
  end
  def topics
    Topic.all.find_all{|t| t.creator_id == self.id}.sort_by{|t| t.date}
  end
  def posts
    Post.all.find_all{|t| t.creator_id == self.id}.sort_by{|p| p.date}
  end
  def discussions
    self.posts.map{|p| p.topic}.uniq.sort_by{|t| t.date}
  end
  def events
    Event.all.find_all{|e| e.attendee_ids.include?(self.id)}.sort_by{|e| e.date}
  end
  
  def member_since
    fuzzy_time_since(Time.at(self.date))
  end
  
  save_callback :before, :set_permalink
  
  def set_permalink
    self.permalink = generate_permalink(self.name)
  end
  
  
  def set_password(password)
    self.salt = 64.times.map{|l|('a'..'z').to_a[rand(25)]}.join
    self.password_hash = (Digest::SHA2.new(512) << (self.salt + password + "thyuhwdhlbajhrqmdwxgayegpjxjdomaj")).to_s
  end
  def valid_password?(password)
    return false if (self.password_hash.nil? || self.salt.nil?)
    return ((Digest::SHA2.new(512) << (self.salt + password + "thyuhwdhlbajhrqmdwxgayegpjxjdomaj")).to_s == password_hash)
  end

  property :password_hash
  property :salt
  property :challenges
  
end
