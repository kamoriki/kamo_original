class CreateContributions < ActiveRecord::Migration[6.1]
  def change
    create_table :contributions do |t|
      t.references :user
      t.string :user_name
      t.string :shop_name
      t.string :item_name
      t.string :item_url
      t.string :message
      t.string :item_image
      t.timestamps null: false
  end
  end
end
