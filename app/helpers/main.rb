class Main
  helpers do
    
    def random_question
      question_words = %w{Who What When Where Why How}
      verb_words = %w{can will do makes does}
      pronouns = %w{he she they we}
      action = %w{explode play hug kick throw}
      return [question_words[rand(6)], verb_words[rand(5)], pronouns[rand(4)], action[rand(5)]].join(" ") + "?"
    end
    
    def random_answer
      answer_words = %w{Because}
      pronouns = %w{he she they we}
      verb_words = %w{can will do makes does}
      action = %w{explode play hug kick throw}
      return [answer_words[rand(1)], pronouns[rand(4)], verb_words[rand(5)], action[rand(5)]].join(" ") + "."
    end
    
    def logged_in?
      return false unless request.cookies.has_key?("user_challenge") && request.cookies.has_key?("user")
      
      @user = User.get(request.cookies['user'])
      return false if @user.nil?
      
      @user = nil unless @user.challenges && @user.challenges.include?(request.cookies['user_challenge'])
      return false if @user.nil?
      
      current_time = Time.now.to_i
      $current_users[@user.id] = current_time
      $current_users.delete_if{|u_id, time| (time + 5*60) < current_time}
      
      return true
    end
    
    def events_by_visible_month(events, date)
      #returns all events that will be visible date's month view
      
      start_date = (date.beginning_of_month.beginning_of_week).to_i
      end_date = (start_date + 35.days).to_i
      return events.find_all{|e| e.date > start_date && e.date < end_date}
    end
    
    def events_by_week(events, date)
      #returns all events within a given week
      start_date = (date.beginning_of_week).to_i
      end_date = (start_date + 7.days).to_i
      return events.find_all{|e| e.date > start_date && e.date < end_date}
    end
    
    def events_by_day(events, date)
      #returns all events that are on the same day as date
    end
    
    def events_by_hour(events, date)
      #returns all events that are between date and date + 1 hour
      
    end


    # Your helpers go here. You can also create another file in app/helpers with the same format.
    # All helpers defined here will be available across all the application.
    #
    # @example A helper method for date formatting.
    #
    #   def format_date(date, format = "%d/%m/%Y")
    #     date.strftime(format)
    #   end
  end
end
