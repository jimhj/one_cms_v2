class TokenWithdraw < ActiveRecord::Base
  belongs_to :user_token
  delegate :token, to: :user_token

  validates_presence_of :amount, :address, on: :create
  validates_numericality_of :amount, greater_than: 0, on: :create

  store :extras, accessors: [:user_token_snapshot]

  enum state: {
    pending:          0,
    processing:       5,
    completed:        10,
    rejected:         -10
  }

  def self.state_mapping
    {
      'pending' => '待处理',
      'processing' => '处理中',
      'completed' => '已完成'
      # 'rejected' => '拒绝受理'
    }
  end

  def state_text
    self.class.state_mapping[self.state]
  end

  def user
    user_token.user
  end
end
