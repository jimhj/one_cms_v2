class ActiveToken < ActiveRecord::Base
  enum state: {
    pending: 0,
    actived: 10
  }

  EXPIRED_TIME = 3.days

  def self.check(token)
    t = self.find_by(token: token)
    return false if t.nil?
    return false if t.actived?

    if Time.now - t.created_at > EXPIRED_TIME
      return false
    end

    t
  end

  def self.g_mobile_active_code(mobile)
    t = ActiveToken.new
    t.receiver = mobile

    loop do 
      active_code = '%06d' % SecureRandom.random_number(999999)
      if not self.where(token: active_code, receiver: mobile, state: 0).first
        t.token = active_code
        break
      end
    end
    
    t.save
    t   
  end

  def self.g_email_active_code(email)
    g_mobile_active_code(email)
  end

  def self.send_active_code(mobile)
    token = g_mobile_active_code(mobile)
    param_string = { code: token.token }.to_json
    Aliyun::Sms.send(mobile, Setting.alisms.template.activation, param_string)
  end

  def self.send_email_code(email)
    token = g_email_active_code(email)
    # UserMailer.delay(queue: 'mailing').activation_email(token)
    UserMailer.activation_email(token).deliver!
  end
end
