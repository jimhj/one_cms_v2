class User < ActiveRecord::Base
  has_secure_password
  
  has_many :articles
  has_many :comments

  mount_uploader :avatar, AvatarUploader
  
  validates :email, presence: true, uniqueness: true, on: [:email_regist]
  validates :mobile, presence: true, uniqueness: true, on: [:mobile_regist]
  validates :username, presence: { case_sensitive: false }, format: { with: /\A[\p{Word}\w\s-]*\z/ }, length: { in: 3..20 }
  validates :password, length: { minimum: 6 }, presence: true, confirmation: true, on: [:create, :reset_password]
  validate :verify_active_code, on: [:mobile_regist]

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

  def g_active_token
    t = ActiveToken.new
    t.receiver = self.email
    t.token = SecureRandom.urlsafe_base64(32)
    t.save
    t
  end

  def active_code
    @verify_code
  end

  def active_code=(new_code)
    @verify_code = new_code
  end

  protected

  def verify_active_code
    t = ActiveToken.where(token: self.active_code, receiver: self.mobile, state: 0).first
    p t
    p !ActiveToken.check(self.active_code)
    
    if t.blank? or !ActiveToken.check(self.active_code)
      errors.add(:active_code, "无效")
    end
  end
end
