class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string(:name, null: false)
      t.decimal(:price, precision: 13, scale: 4, null: false)
      t.integer(:inventory, null: false)

      t.timestamps
    end
  end
end
