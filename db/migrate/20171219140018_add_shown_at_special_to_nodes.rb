class AddShownAtSpecialToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_at_top, :boolean, default: true, after: :is_column
  end
end
