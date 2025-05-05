class ListingPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    user && record.user == user
  end

  def destroy?
    user && record.user == user
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end 