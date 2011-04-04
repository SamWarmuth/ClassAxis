class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  def first_name
    self.name.split(" ").first
  end
  
  property :email
  property :date, :default => Proc.new{Time.now.to_i}
  view_by :date
  
  property :file_ids, :default => []
  
  #standard user is allowed five files < 500k.
  property :max_file_count, :default => 5
  property :max_file_size, :default => 0.5
  
  property :room_ids, :default => []
  
  property :permalink
  view_by :permalink
  
  property :temporary, :default => true
  

  property :is_admin, :default => false
  
  property :picture_url
  
  def rooms
    self.room_ids.map{|r_id| Room.get(r_id)}
  end


  def messages
    Message.by_receiver_id(:key => self.id).sort_by{|m| m.date}
  end
  def sent_messages
    Message.by_sender_id(:key => self.id).sort_by{|m| m.date}
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
