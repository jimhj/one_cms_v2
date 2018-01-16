class CreateUserCreditLogs < ActiveRecord::Migration
  def change
    create_table :user_credit_logs do |t|
      t.belongs_to :user, index: true
      t.integer :comments_count, default: 0
      t.integer :articles_count, default: 0
      t.integer :daily_credits, default: 0
      t.integer :login_number, default: 0
      t.integer :log_day, default: 0, index: true
      t.boolean :logged, default: false
      t.text :extras
      t.timestamps null: false
    end

    add_index :user_credit_logs, [:user_id, :log_day]
  end
end
