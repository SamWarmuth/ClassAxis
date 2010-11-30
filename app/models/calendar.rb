class Calendar < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :date, :default => Proc.new{Time.now.to_i}
  property :name
  property :event_ids, :default => []
  
  property :creator_id
  
  def events
    self.event_ids.map{|e_id| Event.get(e_id)}
  end
end
