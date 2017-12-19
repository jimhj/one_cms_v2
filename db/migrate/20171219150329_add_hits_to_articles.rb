class AddHitsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :hits, :integer, default: 0, after: :focus
  end
end
