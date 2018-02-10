class TokenHongbao < ActiveRecord::Base
  belongs_to :user
  belongs_to :token

  store :extras, accessors: [:token_snapshot]

  scope :today, -> {
    where('created_at >= ? and created_at <= ?', 
          Time.now.at_beginning_of_day,
          Time.now.end_of_day)
  }

  scope :sign_up, -> {
    where(from: 'sign_up')
  }

  scope :comment, -> {
    where(from: 'comment')
  }

  def open!
    return if self.opened?
    
    transaction {
      self.opened = true
      self.save!

      user_token = user.tokens.find_or_initialize_by(token_id: token.id)
      user_token.amount = user_token.amount.to_f + self.amount
      user_token.save!
      user_token
    }
  end
end
