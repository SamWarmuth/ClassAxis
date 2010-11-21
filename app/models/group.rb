class Group < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :abbreviation
  property :is_public
  
  
  property :parent_id
  
  property :user_ids, :default => []
  
  property :wall_id
  property :event_ids, :default => []
  
  property :course_number
  
  property :permalink
  
  save_callback :before, :generate_permalink
  
  def discussions
    Topic.all.find_all{|t| t.tags.include?(self.abbreviation)}
  end
  def members
    self.user_ids.map{|u_id| User.get(u_id)}
  end
  def events
    self.event_ids.map{|e_id| Event.get(e_id)}
  end
  def generate_permalink
    self.permalink = self.name.downcase.split('').find_all{|l| (('a'..'z').to_a+('0'..'9').to_a).to_a.include?(l)}.join
  end
end
