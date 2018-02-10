class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.belongs_to :user
      t.belongs_to :token
      t.float :amount
      t.text :extras
      t.string :address
      t.timestamps null: false
    end
  end
end
