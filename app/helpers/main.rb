class Main
  helpers do
    
    def truncate(string, length)
      return string[0...length] + "#{'...' if string.length > length}"
    end
    
    def logged_in?
      return false unless request.cookies.has_key?("user_challenge") && request.cookies.has_key?("user")
      
      user = User.get(request.cookies['user'])
      return false if user.nil?
      
      return false unless user.challenges && user.challenges.include?(request.cookies['user_challenge'])

      @user = user
      current_time = Time.now.to_i
      $current_users[@user.id] = current_time
      $current_users.delete_if{|u_id, time| (time + 10.minutes) < current_time}
      
      return true
    end
    
    def find_urls(string)
      string.gsub(/\S+@\S+[.]\S+/, "<a href='mailto:\\0'>\\0</a>")
      string.gsub(/\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/) {|m| "<a target='_blank' href=#{'http://' unless $2.include?('http')}"+$1+'>'+$1+'</a>'}
    end
    
    def combine_ids(id1, id2)
      #Take two ids, return unique third id.
      #Currently just adds chars then divides by two. Make something better later.
      
      output = []
      id1.length.times do |i|
        output[i] = ((id1[i] + id2[i])/2).round
      end
      output.map(&:chr).join
      
    end

  end
  
  

end
