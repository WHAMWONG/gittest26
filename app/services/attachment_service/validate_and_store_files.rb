
module AttachmentService
  class ValidateAndStoreFiles
    ACCEPTED_CONTENT_TYPES = ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/svg+xml']
    MAX_FILE_SIZE = 100.megabytes

    def self.call(attachments:, todo:)
      new(attachments, todo).execute
    end

    def initialize(attachments, todo)
      @attachments = attachments
      @todo = todo
      @attachment_ids = []
    end

    def execute
      # Ensure @attachments is not nil before calling each
      (@attachments || []).each do |file|
        if ACCEPTED_CONTENT_TYPES.include?(file.content_type) && file.size <= MAX_FILE_SIZE
          attachment = Attachment.create!(todo: @todo, file: file)
          @attachment_ids << attachment.id
        else
          # Handle invalid file types or sizes according to your app's requirements
        end
      end
      @attachment_ids
    end
  end
end

AttachmentService::ValidateAndStoreFiles.call(attachments: @attachments, todo: @todo)
