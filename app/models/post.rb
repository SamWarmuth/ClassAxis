class Post < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :user_id
  property :parent_id
  
  property :content
  property :permalink

  def children
    Post.all.find_all{|p| p.parent_id == self.id}
  end
end
