class Cart < ApplicationRecord
  belongs_to :user

  before_create do
    self.token = SecureRandom.uuid
  end

  def cart_items
    return {} if items_hash.nil?

    JSON.parse(items_hash)
  rescue JSON::ParserError
    {}
  end

  def items
    return [] if items_hash.blank?

    products = Product.where(id: cart_items.keys)
    products.map do |product|
      item = product.as_json(only: %i[id name price])
      item['quantity'] = cart_items[product.id.to_s]
      item
    end
  end

  def total_price
    items.sum { |item| item['price'] * item['quantity'] }
  end
end
