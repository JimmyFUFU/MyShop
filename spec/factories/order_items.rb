FactoryBot.define do
  factory :order_item do
    name { 'order_item_name' }
    price { 3 }
    quantity { 3 }
  end
end