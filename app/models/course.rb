class Course < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :student_ids
  property :events

end
