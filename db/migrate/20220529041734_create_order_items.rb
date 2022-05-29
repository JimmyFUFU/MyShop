class CreateOrderItems < ActiveRecord::Migration[5.0]
  def change
    create_table :order_items do |t|
      t.references(:order)
      t.references(:product)
      t.string(:name)
      t.decimal(:price, precision: 13, scale: 4)
      t.integer(:quantity)

      t.timestamps
    end
  end
end
