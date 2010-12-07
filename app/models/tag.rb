class Tag < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :date
  property :creator_id
end
