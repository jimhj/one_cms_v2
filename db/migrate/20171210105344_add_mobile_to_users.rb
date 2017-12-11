class AddMobileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile, :string, default: nil, after: :email
  end
end
