class Message < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :sender_id
  view_by :sender_id
  
  property :receiver_id
  view_by :receiver_id
  
  property :date, :default => Proc.new{Time.now.to_i}
  property :content, :default => ""

  property :unread, :default => true
  
  property :previous
  property :next
  
  def short_date
    Time.at(self.date).strftime("%b %d")
  end
  def time_since
    fuzzy_time(Time.at(self.date))
  end
end
