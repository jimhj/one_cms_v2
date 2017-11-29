class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article

  validates :content, presence: true, length: { maximum: 500 }
end
