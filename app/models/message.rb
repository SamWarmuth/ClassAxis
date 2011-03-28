class Message < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :sender_id
  view_by :sender_id
  
  property :date, :default => Proc.new{Time.now.to_i}
  property :content, :default => ""
  property :upload_id
  
  def short_date
    Time.at(self.date).strftime("%b %d")
  end
  def time_since
    relative_time(Time.at(self.date))
  end
end
