class Post < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :user_id
  property :parent_id
  
  property :content
  property :permalink

end
