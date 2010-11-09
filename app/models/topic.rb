class Topic < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :title
  property :content
  property :tags
  property :user_id
  
  def children
    Post.all.find_all{|p| p.parent_id == self.id}
  end

end
