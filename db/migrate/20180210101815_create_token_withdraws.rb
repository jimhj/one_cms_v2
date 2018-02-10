class CreateTokenWithdraws < ActiveRecord::Migration
  def change
    create_table :token_withdraws do |t|
      t.belongs_to :user_token
      t.float :amount
      t.integer :state, default: 0
      t.text :extras
      t.string :address
      t.timestamps null: false
    end
  end
end
