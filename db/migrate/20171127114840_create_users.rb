class CreateUsers < ActiveRecord::Migration
  def change    
    create_table :users do |t|
      t.string :email, unique: true, null: false
      t.string :username, null: false
      t.string :password_digest, null: false
      t.string :private_token
      t.string :avatar

      t.datetime :remember_created_at

      t.integer :state, default: 0

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string   :allowed_node_ids
      t.boolean :review_later, default: true
      t.text :extras

      t.timestamps null: false
    end
  end
end
