# frozen_string_literal: true

module TodoService
  class AssociateTags < BaseService
    def initialize(todo_id, tag_ids)
      @todo_id = todo_id
      @tag_ids = tag_ids
    end

    def execute
      todo = Todo.find_by(id: @todo_id)
      raise ActiveRecord::RecordNotFound, 'Todo not found' unless todo

      @tag_ids.each do |tag_id|
        tag = Tag.find_by(id: tag_id)
        raise ActiveRecord::RecordNotFound, "Tag with id #{tag_id} not found" unless tag

        TodoTag.find_or_create_by(todo_id: @todo_id, tag_id: tag_id)
      end

      { association_status: true }
    rescue ActiveRecord::RecordNotFound => e
      { association_status: false, error: e.message }
    rescue StandardError => e
      { association_status: false, error: e.message }
    end
  end
end

# End of AssociateTags service
