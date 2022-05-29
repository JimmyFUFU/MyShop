class CreateCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :carts do |t|
      t.references(:user)
      t.string(:token, null: false)
      t.string(:items_hash, default: '{}')
      t.timestamps
    end
  end
end
