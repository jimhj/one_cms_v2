class AddExtrasToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :nav_color, :string, after: :nav_name
    add_column :nodes, :extras, :text, after: :nav_color
  end
end
