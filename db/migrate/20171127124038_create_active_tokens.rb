class CreateActiveTokens < ActiveRecord::Migration
  def change
    create_table :active_tokens do |t|
      t.string :receiver, null: false
      t.string :token, null: false
      t.integer :state, default: 0
      t.text :extras
      t.timestamps null: false
    end
  end
end
