class User < ActiveRecord::Base
  has_secure_password
  
  has_many :articles
  has_many :comments
  has_many :credit_logs, class_name: 'UserCreditLog'
  has_many :hongbaos, class_name: 'TokenHongbao', foreign_key: :user_id
  has_many :tokens, class_name: 'UserToken', foreign_key: :user_id
  has_many :token_withdraws, through: :tokens

  mount_uploader :avatar, AvatarUploader
  
  validates :email, presence: true, uniqueness: true, on: [:email_regist]
  validates :mobile, presence: true, uniqueness: true, on: [:mobile_regist]
  validates :username, presence: { case_sensitive: false }, format: { with: /\A[\p{Word}\w\s-]*\z/ }, length: { in: 3..20 }
  validates :password, length: { minimum: 6 }, presence: true, confirmation: true, on: [:create, :reset_password]
  validate :verify_active_code, on: [:mobile_regist]
  validate :verify_email_code, on: [:email_regist]

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

  def g_active_token(email)
    # t = ActiveToken.new
    # t.receiver = self.email
    # t.token = SecureRandom.urlsafe_base64(32)
    # t.save
    # t

    ActiveToken.g_email_active_code(email)
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

  def prev_credit_log
    log_day = Time.now.strftime('%Y%m%d').to_i
    credit_logs.order('id DESC').where('log_day < ?', log_day).first
  end

  def init_daily_credits!
    User.transaction do
      log_day = Time.now.strftime('%Y%m%d').to_i
      log = self.credit_logs.find_by(log_day: log_day)
      return log if log.present?

      log = self.credit_logs.build
      log.log_day = log_day

      login_times = if prev_credit_log.nil?
        1
      else
        diff_day = log_day - prev_credit_log.log_day
        diff_day > 1 ? 1 : (self.login_number + 1)
      end

      self.login_number = login_times
      self.save!

      log.login_number = self.login_number
      log.save!

      log
    end
  end

  def log_daily_credits!(day = nil)
    # now = Time.now
    now = Time.now.yesterday
    log_day = day || now.strftime('%Y%m%d').to_i

    log = self.credit_logs.find_by(log_day: log_day)
    return if log.nil?
    return log if log.logged?

    begin_time = now.at_beginning_of_day
    end_time = now.end_of_day
    time_range = "created_at >= ? and created_at <= ?"

    coefficients = UserCreditLog.coefficients

    User.transaction do

      log.comments_count = self.comments.where(time_range, begin_time, end_time).approved.count
      log.articles_count = self.articles.where(time_range, begin_time, end_time).approved.count
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

  def verify_email_code
    t = ActiveToken.where(token: self.active_code, receiver: self.email, state: 0).first
    
    if t.blank? or !ActiveToken.check(self.active_code)
      errors.add(:active_code, "无效")
    end
  end
end
