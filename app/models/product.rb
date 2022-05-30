class Product < ApplicationRecord
  validates :name, uniqueness: true

  def adjust_inventory!(quantity)
    with_lock do
      raise(InventoryNotEnoughError, "商品 #{name} 的庫存不足。") if quantity.negative? && quantity.abs > inventory.to_i

      self.inventory += quantity
      save!
    end
  end
end
