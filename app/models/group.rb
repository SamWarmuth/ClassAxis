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
  
  
  def discussions
    Topic.all.find_all{|t| t.tags.include?(self.permalink)}
  end
  def members
    self.user_ids.map{|u_id| User.get(u_id)}
  end
  def events
    Calendar.get(self.calendar_id).events
  end
end

def generate_permalink(name)
  permalink = name.downcase.split('').find_all{|l| (('a'..'z').to_a+('0'..'9').to_a).to_a.include?(l)}.join
end
