class Post < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :user_id
  property :content
  property :permalink
  property :parent_id

end
