class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_cart
  helper_method :current_cart_items

  def current_cart
    @current_cart ||= find_cart
  end

  def current_cart_items
    @current_cart_items ||= current_cart.items
  end

  def authenticate_user!
    respond_to do |format|
      format.html { super }
      format.json do
        unless current_user
          return render(json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized)
        end
      end
    end
  end

  private

  def find_cart
    cart = current_user.cart || current_user.create_cart
    session[:cart_token] = cart.token
    cart
  end
end
