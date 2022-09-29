class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true
      t.references :contribution, foreign_key: true
      t.string :statement
      t.timestamps null: false
    end
  end
end
