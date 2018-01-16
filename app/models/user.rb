class User < ActiveRecord::Base
  has_secure_password
  
  has_many :articles
  has_many :comments
  has_many :credit_logs, class_name: 'UserCreditLog'

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

  def can_comment?(article = nil)
    last_comment = if article
      article.comments.order('id DESC').first
    else
      comments.order('id DESC').first
    end
    
    return true if last_comment.nil?

    Time.now - last_comment.created_at >= 1.minute
  end

  def last_credit_log
    credit_logs.order('id DESC').first
  end

  def calc_login_number(day = nil)
    return 1 if last_credit_log.nil?
    log_day = day || Time.now.strftime('%Y%m%d').to_i

    return 1 if last_credit_log.log_day - log_day > 1

    if (last_credit_log.log_day - log_day) == 1
      return self.login_number + 1
    end

    return self.login_number
  end

  def init_daily_credits!
    User.transaction do
      log_day = Time.now.strftime('%Y%m%d').to_i
      log = self.credit_logs.find_by(log_day: log_day)
      return log if log.present?

      log = self.credit_logs.build
      log.log_day = log_day
      self.login_number = calc_login_number(log_day)
      self.save!

      log.login_number = self.login_number
      log.save!

      log
    end
  end

  def log_daily_credits!(day = nil)
    now = Time.now
    log_day = day || now.strftime('%Y%m%d').to_i

    log = self.credit_logs.find_by(log_day: log_day)
    return if log.nil?
    return log if log.logged?

    time_range = now.at_beginning_of_day.strftime('%F %T')..now.end_of_day.strftime('%F %T')
    coefficients = UserCreditLog.coefficients

    User.transaction do
      log.comments_count = self.comments.where(created_at: time_range).approved.count
      log.articles_count = self.articles.where(created_at: time_range).approved.count
      log.log_day = log_day
      log.login_number = self.login_number
      log.daily_credits = log.articles_count * coefficients[:article] + 
                          log.comments_count * coefficients[:comment] + 
                          log.login_number * coefficients[:login]
      log.logged = true
      log.save!
      self.credits = self.credits + log.daily_credits
      self.save!
      log
    end
  end

  def rank_number
    users = User.order('credits DESC')
    users.index(self).to_i + 1
  end

  protected

  def verify_active_code
    t = ActiveToken.where(token: self.active_code, receiver: self.mobile, state: 0).first
    
    if t.blank? or !ActiveToken.check(self.active_code)
      errors.add(:active_code, "无效")
    end
  end
end
