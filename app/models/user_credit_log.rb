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
    log_day = 20180130
  
    User.transaction do
      # User.where('id >= 463').each do |user|
      User.all.each do |user|
        user.credit_logs.destroy_all

        log = user.credit_logs.build
        log.comments_count = user.comments.approved.count
        log.articles_count = user.articles.approved.count
        log.log_day = log_day
        log.login_number = user.login_number
        log.daily_credits = log.articles_count * 10 + log.comments_count * 2 + user.login_number * 1
        log.creation = true
        log.logged = true
        log.save!
        # user.login_number = 1
        user.credits = log.daily_credits
        user.save!(validate: false)
        log
      end

      conf = SiteConfig.first
      conf.rank_updated_at = Time.now.yesterday.at_beggin_of_day + 10.hours
      conf.save!
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
