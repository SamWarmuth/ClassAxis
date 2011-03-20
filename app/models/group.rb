class Group < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :abbreviation
  property :is_public
  
  property :date, :default => Proc.new{Time.now.to_i}
  property :calendar_id
  
  property :parent_id
  
  property :user_ids, :default => []
  property :admin_id
  
  property :wall_id
  
  property :course_number
  
  property :permalink
  view_by :permalink
  
  
  def discussions
    Topic.by_group(:key => self.permalink)
  end
  def members
    self.user_ids.map{|u_id| User.get(u_id)}
  end
  def events
    Calendar.get(self.calendar_id).events
  end
end
