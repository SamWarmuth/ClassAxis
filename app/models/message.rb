class Message < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :sender_id
  property :receiver_id
  
  property :date, :default => Time.now.to_s
  property :subject, :default => ""
  property :content, :default => ""

  property :unread, :default => true
  
end
