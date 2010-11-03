class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :email
  
end