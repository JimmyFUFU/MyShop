FactoryBot.define do
  factory :order do
    total_price { 38.35 }
    token { 'order_token' }
  end
end