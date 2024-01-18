class Api::TodosController < ApplicationController
  before_action :set_todo, only: [:associate_categories, :associate_tags]

  # POST /api/todos/:todo_id/categories
  def associate_categories
    category_id = params.require(:category_id)

    result = TodoService::AssociateCategories.new(@todo.id, [category_id]).call

    if result[:association_status]
      render json: {
        status: 201,
        todo_category: {
          todo_id: @todo.id,
          category_id: category_id
        }
      }, status: :created
    else
      error_message = result[:error]
      render json: { error: error_message }, status: error_status(error_message)
    end
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

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id])
    render json: { error: 'Todo item not found.' }, status: :not_found unless @todo
  end

  def tag_params
    params.require(:tag).permit(:tag_id)
  end

  def error_status(error_message)
    case error_message
    when 'Todo not found', 'Category not found', 'Todo not found.', 'Tag not found.'
      :not_found
    else
      :internal_server_error
    end
  end
end
