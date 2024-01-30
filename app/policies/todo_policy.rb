
class TodoPolicy
  attr_reader :user, :todo

  def initialize(user, todo)
    @user = user
    @todo = todo
  end

  # Method create? already exists and fulfills the requirement.
  def create?
    user.present?
  end
end
