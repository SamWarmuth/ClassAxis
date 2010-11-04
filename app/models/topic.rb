class Topic < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :title
  property :head_id
  property :tags

end
