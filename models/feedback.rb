class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :review

  def to_hash
    {
      user: self.user.login,
      content: self.content,
      created_at: self.created_at,
    }
  end
end
