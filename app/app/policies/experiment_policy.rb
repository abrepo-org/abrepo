class ExperimentPolicy < ApplicationPolicy
  def create?
    user.moderator?
  end
end
