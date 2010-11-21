class Event < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :date
  property :time
  property :location
  property :attendee_ids, :default => []
  property :repeat, :default => false
  property :permalink
  
  save_callback :before, :set_permalink
  
  def attendees
    attendee_ids.map{|a_id| User.get(a_id)}
  end
  
  def set_permalink
    self.permalink = generate_permalink(self.name)
  end
end
