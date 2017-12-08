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

    Node.order('lft asc, rgt desc').where(id: node_ids)
  end

  after_create do
    t = g_active_token
    UserMailer.delay(queue: 'mailing').activation_email(t)
  end

  def g_active_token
    t = ActiveToken.new
    t.receiver = self.email
    t.token = SecureRandom.urlsafe_base64(32)
    t.save
    t
  end
end
