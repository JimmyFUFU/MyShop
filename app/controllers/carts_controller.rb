class CartsController < ApplicationController
  prepend_before_action :authenticate_user!
  def show
    respond_to do |format|
      format.html do
        redirect_to(cart_token_carts_path(cart_token: current_cart.token)) if current_cart && !params[:cart_token]
      end
      format.json do
        render(json: current_cart.as_json(only: %i[id token], methods: %i[items total_price]))
      end
    end
  end

  def add_item
    product_availability, message = product_available?
    render_error(message) { return } unless product_availability

    current_items = current_cart.cart_items
    current_items[product.id.to_s] = current_items[product.id.to_s].to_i + params[:quantity].to_i
    current_cart.items_hash = current_items.to_json
    current_cart.save!
    render(json: { success: true, message: '成功加入購物車' })
  end

  def remove_item
    current_items = current_cart.cart_items
    current_items.delete(params[:product_id].to_s)
    current_cart.items_hash = current_items.to_json
    current_cart.save!
    render(json: { success: true, message: '已移除' })
  end

  private

  def product
    @product ||= Product.find(params[:product_id])
  end

  def render_error(error)
    render(json: { success: false, error: error }, status: :unprocessable_entity) and yield
  end

  def product_available?
    if product.nil?
      [false, '查無此商品']
    elsif lack_of_inventory
      [false, '該商品庫存不足']
    else
      [true]
    end
  end

  def lack_of_inventory
    current_cart.cart_items[product.id.to_s].to_i + params[:quantity].to_i > product.inventory
  end
end
