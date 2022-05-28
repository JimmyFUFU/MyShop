# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

# Product
5.times do
  begin
    Product.create!(
      name: Faker::CryptoCoin.coin_name,
      price: Faker::Number.decimal(l_digits: 1),
      inventory: Faker::Number.within(range: 0..100)
    )
  rescue ActiveRecord::RecordInvalid => _e
    next
  end
end

10.times do
  begin
    Product.create!(
      name: Faker::Games::LeagueOfLegends.champion,
      price: Faker::Number.between(from: 1, to: 1000),
      inventory: Faker::Number.within(range: 0..100)
    )
  rescue ActiveRecord::RecordInvalid => _e
    next
  end
end
