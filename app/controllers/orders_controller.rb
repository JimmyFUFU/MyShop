require './lib/exceptions/inventory_errors'

class OrdersController < ApplicationController
  prepend_before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
    render(json: { success: true }.merge(orders: @orders.as_json)) if request.format.json?
  end

  def show
    @order = current_user.orders.find_by!(token: params[:token])
    render(json: { success: true }.merge(@order.as_json(methods: :order_items))) if request.format.json?
  rescue ActiveRecord::RecordNotFound => _e
    render(json: { success: false, error: 'Order Not Found' }, status: :unprocessable_entity)
  end

  def create
    order = current_user.orders.new(token: current_cart.token, total_price: current_cart.total_price)
    create_order_items(order)
    order.save!
    current_cart.destroy!
    flash[:notice] = '成功購買！感謝課金！'
    redirect_to(show_orders_path(token: order.token))
  rescue InventoryError => e
    render(json: { success: false, error: e.message }, status: :unprocessable_entity)
  end

  private

  def create_order_items(order)
    products_from_cart_items.each do |product|
      quantity = current_cart_items.find { |item| item['id'] == product.id }['quantity']
      product.adjust_inventory!(-quantity)
      order.order_items.new(product_id: product.id, name: product.name, price: product.price, quantity: quantity)
    end
  end

  def products_from_cart_items
    products = Product.where(id: current_cart_items.map { |item| item['id'] })
    raise(NoProductError, '購物車中沒有商品') if products.blank?

    products
  end
end
