class Main
  helpers do
    
    def truncate(string, length)
      return string[0..length] + "#{'...' if string.length > length}"
    end
    
    def logged_in?
      return false unless request.cookies.has_key?("user_challenge") && request.cookies.has_key?("user")
      
      user = User.get(request.cookies['user'])
      return false if user.nil?
      
      return false unless user.challenges && user.challenges.include?(request.cookies['user_challenge'])

      @user = user
      current_time = Time.now.to_i
      $current_users[@user.id] = current_time
      $current_users.delete_if{|u_id, time| (time + 5.minutes) < current_time}
      
      return true
    end
    
    def events_from_visible_month(events, date)
      #returns all events that will be visible date's month view
      
      start_date = (date.beginning_of_month.beginning_of_week).to_i
      end_date = (start_date + 35.days).to_i
      return events.find_all{|e| e.date > start_date && e.date < end_date}
    end
    
    def events_from_month(events, date)
      #returns all events that will be visible date's month view
      
      start_date = (date.beginning_of_month)
      return events.find_all{|e| Time.at(e.date).beginning_of_month == start_date}
    end
    
    def events_from_week(events, date)
      #returns all events within a given week
      start_date = (date.beginning_of_week).to_i
      end_date = (start_date + 7.days).to_i
      return events.find_all{|e| e.date > start_date && e.date < end_date}
    end
    
    def events_from_day(events, date)
      #returns all events that are on the same day as date
    end
    
    def events_from_hour(events, date)
      #returns all events that are between date and date + 1 hour
    end
    
    def events_by_day(events)
      #returns events split up into days
      #dates[day] = events on that day
      
      return events.each_with_object({}) do |event, dates|
        day = Time.at(event.date).midnight.to_i
        dates[day] ||= []
        dates[day] << event
      end
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
