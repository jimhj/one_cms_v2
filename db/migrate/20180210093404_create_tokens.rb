class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :name
      t.float :total, null: false
      t.integer :hongbao_number, null: false
      t.float :available_total
      t.string :hongbao_amount_range
      t.datetime :start_time
      t.datetime :end_time
      t.text :token_desc
      t.string :official_site
      t.text :gift_words
      t.text :qr_code
      t.string :token_logo
      t.boolean :actived
      t.text :extras
      t.timestamps null: false
    end
  end
end
