class Group < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :is_public
  
  property :parent_id
  
  property :user_ids
  
  property :wall_id
  property :events
  
  property :class_number

end
