json.status 201
json.todo_tag do
  json.todo_id @todo_tag.todo_id
  json.tag_id @todo_tag.tag_id
end
