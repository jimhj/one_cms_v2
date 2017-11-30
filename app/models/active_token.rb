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
end
