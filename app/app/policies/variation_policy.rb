class VariationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if !user.nil? && user.moderator?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end

  def update?
    !user.nil? && user.moderator?
  end

end
