class AddNodeIdApprovedIndexToArticles < ActiveRecord::Migration
  def change
    add_index :articles, [:node_id, :approved]
  end
end
