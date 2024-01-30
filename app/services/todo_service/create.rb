# frozen_string_literal: true

module TodoService
  class Create
    attr_reader :user_id, :title, :description, :due_date, :priority, :recurrence, :category_ids, :tag_ids, :attachments

    def initialize(user_id:, title:, description: nil, due_date:, priority: nil, recurrence: nil, category_ids: [], tag_ids: [], attachments: [])
      @user_id = user_id
      @title = title
      @description = description
      @due_date = due_date
      @priority = priority
      @recurrence = recurrence
      @category_ids = category_ids
      @tag_ids = tag_ids
      @attachments = attachments
    end

    def call
      user = User.find(user_id)
      raise 'User not found' unless user

      raise 'Title cannot be blank' if title.blank?
      raise 'Title must be unique' if user.todos.exists?(title: title)

      raise 'Due date must be in the future' if due_date.past?

      if priority.present? && !Todo.priorities.keys.include?(priority)
        raise 'Invalid priority value'
      end

      if recurrence.present? && !Todo.recurrences.keys.include?(recurrence)
        raise 'Invalid recurrence value'
      end

      ActiveRecord::Base.transaction do
        todo = user.todos.create!(
          title: title,
          description: description,
          due_date: due_date,
          priority: priority,
          recurrence: recurrence
        )

        category_ids.each do |category_id|
          category = Category.find_by(id: category_id)
          raise 'Invalid category' unless category
          TodoCategory.create!(todo: todo, category: category)
        end

        tag_ids.each do |tag_id|
          tag = Tag.find_by(id: tag_id)
          raise 'Invalid tag' unless tag
          TodoTag.create!(todo: todo, tag: tag)
        end

        attachments.each do |attachment|
          todo.attachments.create!(file: attachment)
        end

        { todo_id: todo.id }
      end
    rescue ActiveRecord::RecordInvalid => e
      { error: e.message }
    rescue => e
      { error: e.message }
    end
  end
end
