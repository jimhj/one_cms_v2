class TokenWithdraw < ActiveRecord::Base
  belongs_to :user_token
  delegate :token, to: :user_token
end
