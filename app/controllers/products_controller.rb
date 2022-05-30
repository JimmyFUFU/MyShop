class ProductsController < ApplicationController
  def index
    @products = Product.all
    render(json: { success: true }.merge(products: @products.as_json)) if request.format.json?
  end
end
