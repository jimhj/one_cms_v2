class AddNoFollowToLinks < ActiveRecord::Migration
  def change
    add_column :links, :nofollow, :boolean, default: false
  end
end
