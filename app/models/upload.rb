class Upload < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :file_type
  property :date, :default => Proc.new{Time.now.to_i}
  
  property :file_size
  property :image_size
  
  property :url
  property :file_path
  property :date_created
  
  
  def set_size
    image = MiniMagick::Image.open(self.file_path)
    self.image_size = [image[:width], image[:height]]
    self.save
  end
  
  def chat_size
    if self.image_size[0] > 350
      return [350, (self.image_size[1]*(350/self.image_size[0].to_f)).to_i]
    end
    return self.image_size
  end
  
  def preview_supported?
    ['png', 'jpg', 'jpeg', 'gif'].include?(self.file_type)
  end
  
end