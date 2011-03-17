class Upload < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :file_type
  
  property :url
  property :file_path
  property :date_created
  
end