class Tag < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name

end
