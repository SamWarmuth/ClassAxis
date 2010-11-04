class Event < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :date
  property :time
  property :location
  property :attendee_ids
  property :repeat

end
