class Room < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER

  property :name
  property :is_public, :default => true
  
  property :date, :default => Proc.new{Time.now.to_i}
  
  property :admin_id
  
  
  property :permalink
  view_by :permalink
  
  def set_permalink
    self.permalink = generate_permalink(self, self.name)
  end
  
  def messages
    Message.by_room_id(:key => self.id).sort_by{|m| m.date}
  end
  def user_count
    User.all.find_all{|u| u.room_ids.include?(self.id)}.count #needs optimization.
  end
  def last_message
    messages = Message.by_room_id(:key => self.id)
    return 0 if messages.empty?
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