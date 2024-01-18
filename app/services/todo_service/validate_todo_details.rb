# frozen_string_literal: true

module TodoService
  class ValidateTodoDetails
    def initialize(user, title, due_date)
      @user = user
      @title = title
      @due_date = due_date
    end

    def execute
      return { validation_status: false, error_message: I18n.t('activerecord.errors.messages.taken') } if title_exists?
      return { validation_status: false, error_message: I18n.t('activerecord.errors.messages.datetime_in_future') } unless due_date_valid?

      { validation_status: true }
    rescue StandardError => e
      { validation_status: false, error_message: e.message }
    end

    private

    def title_exists?
      @user.todos.exists?(title: @title)
    end

    def due_date_valid?
      @due_date.is_a?(DateTime) && @due_date > DateTime.now
    end
  end
end
