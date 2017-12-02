class AddSecondaryFocusColumnToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :secondary_focus, :boolean, default: false, after: :focus
  end
end
