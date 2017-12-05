class AddIsColumnToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_column, :boolean, default: false, after: :is_nav
    add_column :nodes, :logo, :string, after: :is_column
  end
end
