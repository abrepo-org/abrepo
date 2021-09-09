class ExperimentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if !user.nil? && user.moderator?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end

  def create?
    !user.nil? && user.moderator?
  end

  def index?
    !user.nil? && user.moderator?
  end

end
