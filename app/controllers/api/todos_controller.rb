class Api::TodosController < ApplicationController
  before_action :set_todo, only: [:associate_categories, :associate_tags]
  include TodoService
  include Pundit::Authorization

  # POST /api/v1/todos/validate
  def validate
    title = params.require(:title)
    due_date = params.require(:due_date)

    begin
      due_date = DateTime.parse(due_date)
    rescue ArgumentError
      return render json: { error: 'The request body or parameters are in the wrong format.' }, status: :unprocessable_entity
    end

    validation_service = TodoService::ValidateTodoDetails.new(current_user, title, due_date)
    validation_result = validation_service.execute

    if validation_result[:validation_status]
      render json: { status: 200, message: 'Todo item details are valid.' }, status: :ok
    else
      error_message = validation_result[:error_message]
      status = case error_message
               when I18n.t('activerecord.errors.messages.taken')
                 :conflict
               when I18n.t('activerecord.errors.messages.datetime_in_future')
                 :unprocessable_entity
               else
                 :bad_request
               end
      render json: { error: error_message }, status: status
    end
  end

  # ... existing code for other actions ...

end
