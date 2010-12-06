class Topic < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :title
  property :content, :default => ""
  property :tags, :default => []
  
  property :creator_id
  view_by :creator_id
  
  property :date, :default => Proc.new{Time.now.to_i}
  
  property :permalink
  view_by :permalink
  
  def topic
    self
  end
  def creator
    User.get(self.creator_id)
  end
  
  def children
    Post.by_parent_id(:key => self.id).sort_by{|p| p.date}.reverse
  end
  def time_since
    fuzzy_time_since(Time.at(self.date))
  end
  

end
