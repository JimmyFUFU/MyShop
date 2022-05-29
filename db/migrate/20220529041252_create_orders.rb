class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references(:user)
      t.decimal(:total_price, precision: 13, scale: 4, null: false)
      t.string(:token, null: false)
      t.string(:name, null: false)

      t.timestamps
    end
  end
end
