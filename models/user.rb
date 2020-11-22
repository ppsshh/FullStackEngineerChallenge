class User < ActiveRecord::Base
  has_many :feedbacks
  has_many :assignments
  has_many :reviews, through: :assignments

  def admin?
    # Treat user as admin if username contains 'admin' (case insensitive)
    self.login =~ /admin/i
  end

  def available_reviews
    admin? ? Review.all : self.reviews
  end
end
