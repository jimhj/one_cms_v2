class AddSecondaryFocusIndexToArticles < ActiveRecord::Migration
  def change
    add_index :articles, :secondary_focus
  end
end
