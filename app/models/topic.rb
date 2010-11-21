class Topic < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :title
  property :content, :default => ""
  property :tag_ids, :default => []
  property :creator_id
  property :date, :default => Time.now.to_s
  property :permalink
  
  def tags
    self.tag_ids.map{|t_id| Tag.get(t_id).name}
  end
  def creator
    User.get(self.creator_id)
  end
  
  def children
    Post.all.find_all{|p| p.parent_id == self.id}
  end
  def time_since
    fuzzy_time_since(Time.parse(self.date))
  end
  
  save_callback :before, :set_permalink
  
  def set_permalink
    self.permalink = generate_permalink(self.title)
  end
end
