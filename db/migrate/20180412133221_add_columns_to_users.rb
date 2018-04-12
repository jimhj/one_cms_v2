class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wx_openid, :string, default: nil, after: :login_number
    add_column :users, :wx_unionid, :string, default: nil, after: :wx_openid
  end
end
