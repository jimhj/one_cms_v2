class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user, index: true
      t.belongs_to :article, index: true
      t.belongs_to :to_user
      t.belongs_to :reply_to
      t.text :content
      t.boolean :approved, default: true
      t.text :extras
      t.timestamps null: false
    end
  end
end
