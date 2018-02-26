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

  def self.random_send
    # users = User.where("email like '%71235%'")
    users = User.all

    users.each do |u|
      (20180214..20180223).to_a.each do |t|
        [1,2,3].sample.times do
          created_at = rand(t.to_s.to_datetime.at_beginning_of_day..t.to_s.to_datetime.end_of_day)

          token = Token.all.to_a.sample

          hongbao = token.hongbaos.build

          amount = if token.available_total <= token.max_hongbao_number
            [*token.min_hongbao_number..token.available_total].sample
          else
            [*token.min_hongbao_number..token.max_hongbao_number].sample
          end

          next if (token.exceed_max_hongbao_number? or token.ranout?)

          hongbao.user = u
          hongbao.amount = amount
          hongbao.token_snapshot = token.as_json
          hongbao.from = 'comment'
          hongbao.created_at = created_at
          hongbao.updated_at = created_at
          hongbao.save!

          token.available_total = token.available_total - amount
          token.save!
        end
      end
    end
  end
end
