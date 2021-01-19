# == Schema Information
#
# Table name: actions
#
#  id         :bigint           not null, primary key
#  actionType :string
#  crawlId    :string
#  selector   :string
#  url        :string
#  waitfor    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  a_id       :string
#

#Current Notes / Thoughts
#it's tempting to fold actions into a renderable, but . . .
#
#1. If we want to filter renderables by an action; having to check all
#by an action field or "type is pretty wasteful when it could just be
#an instance
#
#2. action subobject would entail duplication on submit time
#
#3. matches architecture in abrender
#
#4. we can submit only the relevant renderables (ignore renderables
#with no experiment content) assume if a renderable exists, it has visible content.
#
#5. we also can have experiment content across multiple actions, so
#also multiple renderables. This would be responsibility of
#frontend/react - not necessarily data model - which would just
#receive a variation id query for the above.

class Action < ApplicationRecord
  has_many :renderables
  has_many :variations, through: :renderables

  validates :a_id, :url, presence: true


  def to_render(options = {})
    self.slice(:id, :actionType, :crawlId, :selector, :url, :waitfor)
  end

end
