class User < ActiveRecord::Base
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, on: :create
  validates :username, presence: { case_sensitive: false }, format: { with: /\A[\p{Word}\w\s-]*\z/ }, length: { in: 3..20 }
  validates :password, length: { minimum: 6 }, presence: true, confirmation: true, on: [:create, :reset_password]
end
