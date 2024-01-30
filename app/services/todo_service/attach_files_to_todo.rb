# Service to attach files to a todo item
module TodoService
  class AttachFilesToTodo
    def initialize(todo_id, attachments, user)
      @todo_id = todo_id
      @attachments = attachments
      @user = user
    end

    def execute
      todo = validate_todo(@todo_id, @user)
      stored_files_data = validate_and_store_files(@attachments, todo)
      attachment_ids = create_attachments(@todo_id, stored_files_data)
      attachment_ids
    end

    private

    def validate_todo(todo_id, user)
      TodoService::ValidateTodo.new(todo_id, user).execute
    end

    def validate_and_store_files(attachments, todo)
      AttachmentService::ValidateAndStoreFiles.new(attachments, todo).execute
    end

    def create_attachments(todo_id, stored_files_data)
      AttachmentService::CreateAttachments.new(todo_id, stored_files_data).execute
    end
  end
end
