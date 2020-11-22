class AddReviewsAndFeedbacksTables < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.text :content
      t.belongs_to :user
      t.timestamps
    end
    create_table :feedbacks do |t|
      t.belongs_to :user
      t.belongs_to :review
      t.text :content
      t.timestamps
    end
    create_table :assignments do |t|
      t.belongs_to :review
      t.belongs_to :user
      t.boolean :fulfilled, default: false
    end
  end
end
