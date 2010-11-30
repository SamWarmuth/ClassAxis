class Topic < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :title
  property :content, :default => ""
  property :tags, :default => []
  property :creator_id
  property :date, :default => Proc.new{Time.now.to_i}
  property :permalink
  
  def topic
    self
  end
  def creator
    User.get(self.creator_id)
  end
  
  def children
    Post.all.find_all{|p| p.parent_id == self.id}
  end
  def time_since
    fuzzy_time_since(Time.at(self.date))
  end
  
  save_callback :before, :set_permalink
  
  def set_permalink
    self.permalink = generate_permalink(self.title)
  end
end
