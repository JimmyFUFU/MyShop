class InventoryError < StandardError; end

class InventoryNotEnoughError < InventoryError; end

class NoProductError < InventoryError; end
