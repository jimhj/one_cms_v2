class CreateTokenHongbaos < ActiveRecord::Migration
  def change
    create_table :token_hongbaos do |t|
      t.belongs_to :user, index: true
      t.belongs_to :token, index: true
      t.float :amount, default: 0.0
      t.text :extras
      t.boolean :opened, default: 0
      t.string :from, default: 'sign_up'
      t.timestamps null: false
    end
  end
end
