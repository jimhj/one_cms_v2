class User < ActiveRecord::Base
  has_secure_password
  
  has_many :articles
  has_many :comments

  mount_uploader :avatar, AvatarUploader
  
  validates :email, presence: true, uniqueness: true
  validates :username, presence: { case_sensitive: false }, format: { with: /\A[\p{Word}\w\s-]*\z/ }, length: { in: 3..20 }
  validates :password, length: { minimum: 6 }, presence: true, confirmation: true, on: [:create, :reset_password]

  store :extras

  enum state: {
    pending: 0,
    actived: 1
  }

  def allowed_nodes
    if self.allowed_node_ids == '*'
      return Node.all
    end

    node_ids = (self.allowed_node_ids.presence || '').split('|')
    return [] if node_ids.blank?

    Node.where(id: node_ids)
  end
end
