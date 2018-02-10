class Token < ActiveRecord::Base
  mount_uploader :token_logo, TokenLogoUploader

  validates_presence_of :name, :code, :total, :hongbao_number, 
                        :available_total, :hongbao_amount_range,
                        :start_time, :end_time, :token_desc, :token_logo,
                        :official_site

  validates_numericality_of :hongbao_number, greater_than: 0
  validate :validate_time_range, on: :create

  has_many :hongbaos, class_name: 'TokenHongbao', foreign_key: :token_id

  def self.available(user = nil)
    self.select{ |t| t.available? }
  end

  def available?
    start? && !finished? && !exceed_max_hongbao_number? && !ranout?
  end

  def hongbao_range
    (self.hongbao_amount_range || '').split('|')
  end

  def min_hongbao_number
    hongbao_range.first.to_i
  end

  def max_hongbao_number
    hongbao_range.last.to_i
  end

  def hongbao_range_text
    hongbao_range.join(' ~ ')
  end

  def validate_time_range
    if start_time >= end_time
      errors.add(:end_time, '必须大于起始时间')
    end

    if end_time <= Time.now
      errors.add(:end_time, '必须大于当前时间')
    end
  end

  def start?
    self.start_time >= Time.now
  end

  def finished?
    self.end_time <= Time.now
  end

  def exceed_max_hongbao_number?
    hongbaos.count >= self.hongbao_number
  end

  def ranout?
    self.available_total < self.min_hongbao_number
  end

  def send_hongbao_to(user, from = 'sign_up')
    amount = if self.available_total <= max_hongbao_number
      [*min_hongbao_number..available_total].sample
    else
      [*min_hongbao_number..max_hongbao_number].sample
    end

    return if !available?

    hongbao = self.hongbaos.build

    self.transaction {
      hongbao.user = user
      hongbao.amount = amount
      hongbao.token_snapshot = self.as_json
      hongbao.from = from
      hongbao.save!

      self.available_total = self.available_total - amount
      self.save!
    }

    hongbao
  end
end
