class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  belongs_to :reply_user, class_name: 'User', foreign_key: 'to_user_id'
  belongs_to :reply_comment, class_name: 'Comment', foreign_key: 'reply_to_id'

  validates :content, presence: true, length: { maximum: 500 }

  scope :approved, -> { where(approved: true) }

  scope :today, -> {
    where('created_at >= ? and created_at <= ?', 
          Time.now.at_beginning_of_day,
          Time.now.end_of_day)
  }

  def floor_number
    article.comments.index(self).to_i + 1
  end

  def can_send_hongbao?
    comment_hongbao_count = user.hongbaos.comment.today.count

    allow_nodes = Node.where(id: [223, 212, 232, 233]).collect do |n|
      n.self_and_descendants.pluck(:id)
    end.flatten.uniq

    (user.comments.approved.today.select{ |c| allow_nodes.include?(c.article.node.id) }.map(&:article_id).uniq.size >= (comment_hongbao_count+1) * 3) \
      && comment_hongbao_count < 3
  end
end
