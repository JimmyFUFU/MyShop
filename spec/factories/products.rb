FactoryBot.define do
  factory :product do
    name { 'product' }
    price { 50 }
    inventory { 10 }

    trait :sold_out do
      inventory { 0 }
    end
  end

  factory :luna, parent: :product do
    name { 'luna' }
    price { 100 }
  end

  factory :ust, parent: :product do
    name { 'ust' }
    price { 30 }
  end
end
