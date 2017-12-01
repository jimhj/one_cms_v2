class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article

  validates :content, presence: true, length: { maximum: 500 }

  def floor_number
    article.comments.index(self).to_i + 1
  end
end
