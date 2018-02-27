class AddIsShownToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_shown, :boolean, default: true, after: :is_column
  end
end
