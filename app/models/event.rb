class Event < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :location
  property :description
  property :tags, :default => []
  
  property :date
  view_by :date
  
  property :repeat, :default => false
  
  
  property :attendee_ids, :default => []
  property :permalink
  view_by :permalink
  
    
  def calendar
    return Calendar.all.find{|c| c.event_ids.include?(self.id)}
  end
  
  def attendees
    attendee_ids.map{|a_id| User.get(a_id)}
  end
  
  def set_permalink
    self.permalink = generate_permalink(self, self.name)
  end
  def fuzzy_date
    fuzzy_time(Time.at(self.date))
  end
end
