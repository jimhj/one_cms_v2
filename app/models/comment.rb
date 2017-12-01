class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  belongs_to :reply_user, class_name: 'User', foreign_key: 'to_user_id'
  belongs_to :reply_comment, class_name: 'Comment', foreign_key: 'reply_to_id'

  validates :content, presence: true, length: { maximum: 500 }

  def floor_number
    article.comments.index(self).to_i + 1
  end
end
