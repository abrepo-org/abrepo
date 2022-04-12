class ProfilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if !user.nil? && user.moderator?
        scope.all.includes(:experiments)
      else
        scope
          .includes(:experiments)
          .where(experiments: {published: true})
      end
    end
  end
end
