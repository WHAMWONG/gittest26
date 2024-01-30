# frozen_string_literal: true

module TodoService
  class AssociateCategories < BaseService
    attr_reader :todo_id, :category_ids

    def initialize(todo_id, category_ids)
      @todo_id = todo_id
      @category_ids = category_ids
    end

    def call
      todo = Todo.find_by(id: todo_id)
      raise ActiveRecord::RecordNotFound, 'Todo not found' unless todo

      category_ids.each do |category_id|
        category = Category.find_by(id: category_id)
        raise ActiveRecord::RecordNotFound, 'Category not found' unless category

        TodoCategory.find_or_create_by(todo_id: todo_id, category_id: category_id)
      end

      { association_status: true }
    rescue ActiveRecord::RecordNotFound => e
      { association_status: false, error: e.message }
    rescue StandardError => e
      { association_status: false, error: e.message }
    end
  end
end
