class Api::TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo, only: [:associate_tags]

  def create
    user_id = request.headers['user_id']
    todo_params = params.permit(:title, :description, :due_date, :priority, :recurrence)

    validation_service = TodoService::Validate.new(todo_params, current_user)
    validation_result = validation_service.call

    if validation_result == true
      create_service = TodoService::Create.new(
        user_id: user_id,
        title: todo_params[:title],
        description: todo_params[:description],
        due_date: todo_params[:due_date],
        priority: todo_params[:priority],
        recurrence: todo_params[:recurrence]
      )

      result = create_service.call

      if result[:todo_id]
        render json: { status: 201, todo: Todo.find(result[:todo_id]) }, status: :created
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    else
      render json: { errors: validation_result }, status: :bad_request
    end
  rescue Pundit::NotAuthorizedError
    render json: { error: 'User is not authorized to create a todo item.' }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found.' }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/todos/:todo_id/tags
  def associate_tags
    tag_id = tag_params[:tag_id]
    service_result = TodoService::AssociateTags.new(@todo.id, [tag_id]).execute

    if service_result[:association_status]
      render json: { status: 201, todo_tag: { todo_id: @todo.id, tag_id: tag_id } }, status: :created
    else
      render json: { error: service_result[:error] }, status: error_status(service_result[:error])
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def authenticate_user!
    # This method should handle user authentication
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def tag_params
    params.require(:tag).permit(:tag_id)
  end

  def error_status(error_message)
    case error_message
    when 'Todo not found.', 'Tag not found.'
      :not_found
    else
      :unprocessable_entity
    end
  end
end
