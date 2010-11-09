class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :email
  property :events
  
  property :picture_url
  
  def groups
    Group.all.find_all{|g| g.class_number.nil? && g.user_ids.include?(self.id)}
  end
  def courses
    Group.all.find_all{|g| !g.class_number.nil? && g.user_ids.include?(self.id)}
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
  
end
