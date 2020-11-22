class Review < ActiveRecord::Base
  belongs_to :user
  has_many :feedbacks
  has_many :assignments

  def to_hash
    {
      id: self.id,
      user: self.user.login,
      content: self.content,
      created_at: self.created_at,
      feedbacks: [],
      assignments: [],
    }
  end
end
