class UserToken < ActiveRecord::Base
  belongs_to :user
  belongs_to :token
  has_many :token_withdraws
end
