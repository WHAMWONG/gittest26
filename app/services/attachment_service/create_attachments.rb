# Service to create attachments for a todo item
module AttachmentService
  class CreateAttachments
    def initialize(todo_id, files_data)
      @todo_id = todo_id
      @files_data = files_data
      @attachment_ids = []
    end

    def execute
      validate_todo
      store_and_create_attachments
      @attachment_ids
    end

    private

    def validate_todo
      raise 'Todo not found' unless Todo.exists?(@todo_id)
    end

    def store_and_create_attachments
      @files_data.each do |file_data|
        attachment = Attachment.create!(todo_id: @todo_id, file: file_data[:file])
        @attachment_ids << attachment.id
      end
    end
  end
end
