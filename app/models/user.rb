class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  def first_name
    self.name.split(" ").first
  end
  
  property :email
  property :date, :default => Proc.new{Time.now.to_i}
  view_by :date
  
  property :calendar_id
  
  property :permalink
  view_by :permalink
  

  property :is_admin, :default => false
  property :broadcast_ids, :default => []
  
  property :picture_url
  
  def calendar
    Calendar.get(self.calendar_id)
  end
  def groups
    Group.all.find_all{|g| g.course_number.nil? && g.user_ids.include?(self.id)}.sort_by{|c| c.name}
  end
  def courses
    Group.all.find_all{|g| !g.course_number.nil? && g.user_ids.include?(self.id)}.sort_by{|c| c.name}
  end
  def messages_by_sender
    messages = Message.by_receiver_id(:key => self.id)
    senders = {}
    messages.each do |message|
      senders[message.sender_id] ||= []
      senders[message.sender_id] << message
    end
    sent = Message.by_sender_id(:key => self.id)
    sent.each do |message|
      senders[message.receiver_id] ||= []
      senders[message.receiver_id] << message
    end
    return senders
  end
  def messages_with(sender)
    sender = sender.id if sender.is_a?(User)
    received = Message.by_receiver_id(:key => self.id).find_all{|m| m.sender_id = sender}
    
    sent = Message.by_receiver_id(:key => sender).find_all{|m| m.sender_id = self.id}
    
    return (received + sent).sort_by{|m| m.date}
  end
  def messages
    Message.by_receiver_id(:key => self.id).sort_by{|m| m.date}
  end
  def sent_messages
    Message.by_sender_id(:key => self.id).sort_by{|m| m.date}
  end
  def topics
    Topic.by_creator_id(:key => self.id).sort_by{|t| t.date}
  end
  def posts
    Post.by_creator_id(:key => self.id).sort_by{|p| p.date}
  end
  def discussions
    self.groups.map{|g| Topic.by_group(:key => g.permalink)}.flatten.compact.sort_by{|t| -1*t.last_post_date}
  end
  def events
    Event.all.find_all{|e| e.attendee_ids.include?(self.id)}.sort_by{|e| e.date}
  end
  def upcoming_events
    now = Time.now.to_i
    Event.all.find_all{|e| e.date > now && e.attendee_ids.include?(self.id)}.sort_by{|e| -e.date}
  end
  def past_events
    now = Time.now.to_i
    Event.all.find_all{|e| e.date < now && e.attendee_ids.include?(self.id)}.sort_by{|e| -e.date}
  end
  
  def member_since
    relative_time(Time.at(self.date))
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
  
  
  def self.newest(count)
    self.by_date(:endkey => Time.now.to_i).reverse[0...count]
  end
end
