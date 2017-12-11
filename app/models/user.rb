class User < ActiveRecord::Base
  has_secure_password
  
  has_many :articles
  has_many :comments

  mount_uploader :avatar, AvatarUploader
  
  validates :email, presence: { allow_blank: true }, uniqueness: { allow_blank: true }
  validates :mobile, presence: { allow_blank: true }, uniqueness: { allow_blank: true }
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

  def g_mobile_active_code
    t = ActiveToken.new
    t.receiver = self.mobile

    loop do 
      active_code = '%06d' % SecureRandom.random_number(999999)
      if not ActiveToken.where(token: active_code, receiver: self.mobile, state: 0).first
        t.token = active_code
        break
      end
    end
    
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
    if t.blank?
      errors.add(:active_code, "验证码不正确")
    end
  end
end
