class Broadcast < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :date, :default => Proc.new{Time.now.to_i}
  property :type, :default => "info"
  property :content
  
  property :announce_to_new_users, :default => false
  
  property :creator_id
  
  def announce
    User.all.each do |user|
      user.broadcast_ids << self.id unless user.broadcast_ids.include?(self.id)
      user.save
    end
  end
  def retract
    User.all.each do |user|
      user.broadcast_ids.delete(self.id)
      user.save
    end
  end
end
