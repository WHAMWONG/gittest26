module TodoService
  class Validate
    include ActiveModel::Validations

    validate :validate_title, :validate_due_date, :validate_priority, :validate_recurrence, :validate_category_ids, :validate_tag_ids

    def initialize(params, user)
      @params = params
      @user = user
    end

    def call
      validate
      errors.empty? ? true : errors.full_messages
    end

    private

    def validate_title
      title = @params[:title]
      if title.blank?
        errors.add(:title, I18n.t('activerecord.errors.messages.blank'))
      elsif @user.todos.exists?(title: title)
        errors.add(:title, I18n.t('activerecord.errors.messages.taken'))
      end
    end

    def validate_due_date
      due_date = @params[:due_date]
      if due_date.blank?
        errors.add(:due_date, I18n.t('activerecord.errors.messages.blank'))
      elsif due_date < Time.current
        errors.add(:due_date, I18n.t('activerecord.errors.messages.datetime_in_future'))
      end
    end

    def validate_priority
      priority = @params[:priority]
      if priority.present? && !Todo.priorities.keys.include?(priority)
        errors.add(:priority, I18n.t('activerecord.errors.messages.in', count: Todo.priorities.keys.join(', ')))
      end
    end

    def validate_recurrence
      recurrence = @params[:recurrence]
      if recurrence.present? && !Todo.recurrences.keys.include?(recurrence)
        errors.add(:recurrence, I18n.t('activerecord.errors.messages.in', count: Todo.recurrences.keys.join(', ')))
      end
    end

    def validate_category_ids
      category_ids = @params[:category_ids] || []
      category_ids.each do |category_id|
        unless @user.categories.exists?(category_id)
          errors.add(:category_ids, I18n.t('activerecord.errors.messages.invalid'))
          break
        end
      end
    end

    def validate_tag_ids
      tag_ids = @params[:tag_ids] || []
      tag_ids.each do |tag_id|
        unless @user.tags.exists?(tag_id)
          errors.add(:tag_ids, I18n.t('activerecord.errors.messages.invalid'))
          break
        end
      end
    end
  end
end
