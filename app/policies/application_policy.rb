class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def destroy_all?
    destroy?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  Scope = Struct.new(:user, :scope) do
    def resolve
      scope
    end
  end
end