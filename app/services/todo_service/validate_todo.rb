# frozen_string_literal: true

module TodoService
  class ValidateTodo
    def initialize(todo_id, user)
      @todo_id = todo_id
      @user = user
    end

    def call
      Todo.find_by!(id: @todo_id, user: @user)
    end
  end
end
