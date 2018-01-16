class UserCreditLog < ActiveRecord::Base
  belongs_to :user

  store :extras, accessors: [:coefficients, :creation]

  before_create do
    self.coefficients = UserCreditLog.coefficients
  end

  def self.coefficients
    { article: 2, comment: 2, login: 1 }
  end

  def self.init!
    log_day = Time.now.at_beginning_of_day.strftime('%Y%m%d').to_i
  
    User.all.each do |user|
      User.transaction do
        user.credit_logs.destroy_all

        log = user.credit_logs.build
        log.comments_count = user.comments.approved.count
        log.articles_count = user.articles.approved.count
        log.log_day = log_day
        log.login_number = 1
        log.daily_credits = log.articles_count * 10 + log.comments_count * 2 + log.login_number * 1
        log.creation = true
        log.logged = true
        log.save!
        user.login_number = 1
        user.credits = log.daily_credits
        user.save!
        log
      end
    end
  end

  def self.log_everyone!
    User.transaction do
      conf = SiteConfig.first
      conf.rank_updated_at = Time.now

      User.all.each do |user|
        user.log_daily_credits!
      end

      conf.save!
    end
  end
end
