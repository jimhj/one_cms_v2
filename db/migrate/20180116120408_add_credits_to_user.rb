class AddCreditsToUser < ActiveRecord::Migration
  def change
    add_column :users, :credits, :integer, default: 0, after: :extras, index: true
    add_column :users, :login_number, :integer, default: 0, after: :credits
  end
end
