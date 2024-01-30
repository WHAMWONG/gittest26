
if @todo.errors.any?
  json.status 422
  json.errors @todo.errors.full_messages
elsif @todo&.persisted?
  json.status 201
  json.todo do
    json.id @todo.id
    json.title @todo.title
    json.description @todo.description
    json.due_date @todo.due_date
    json.priority @todo.priority
    json.recurrence @todo.recurrence || 'none'
    json.user_id @todo.user_id
  end
else
  json.status 500
  json.error "An unexpected error occurred on the server."
end
