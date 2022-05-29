class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items

  before_create do
    self.name = "##{Time.current.to_i}"
  end
end
