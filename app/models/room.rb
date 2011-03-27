class Room < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  view_by :name
  
  property :is_public, :default => true
  view_by :is_public
  
  property :date, :default => Proc.new{Time.now.to_i}
  
  property :admin_id
  
  property :permalink
  view_by :permalink
  
  property :message_ids, :default => []
  
  def public?
    return self.is_public
  end
  def private?
    return !self.is_public
  end
  def set_permalink
    self.permalink = generate_permalink(self, self.name)
  end
  
  def messages(newest = nil)
    return self.message_ids.map{|m_id| Message.get(m_id)} if last.nil?
    
    self.message_ids.last(newest).map{|m_id| Message.get(m_id)}
    
  end
  def files
    self.messages.map(&:upload_id).compact.map{|u_id| Upload.get(u_id)}
  end
  def user_count
    User.all.find_all{|u| u.room_ids.include?(self.id)}.count #needs optimization.
  end
  def last_message
    messages = Message.by_room_id(:key => self.id)
    return Message.new if messages.empty?
    messages.sort_by{|m| m.date}.last
  end
end

def generate_permalink(object, name)
  #remove all characters that aren't a-z or 0-9
  permalink = name.downcase.gsub(/[^a-z^0-9]/,'')
  object_class = CouchRest.constantize(object['couchrest-type'])
  until (object_class.by_permalink(:key => permalink).empty?)
    permalink += rand(10).to_s #add a number to the end.
  end
  return permalink
end