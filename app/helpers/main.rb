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
