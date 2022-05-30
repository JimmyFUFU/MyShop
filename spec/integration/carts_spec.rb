require './spec/swagger_helper'

describe('Cart API') do
  include Warden::Test::Helpers

  let(:user) { FactoryBot.create(:user) }
  let(:product) { FactoryBot.create(:product) }
  let(:luna) { FactoryBot.create(:luna) }
  let(:ust) { FactoryBot.create(:ust) }
  let!(:cart) do
    items = {}
    items[product.id.to_s] = 3
    items[luna.id.to_s] = 2

    FactoryBot.create(:cart, user: user, items_hash: items.to_json)
  end
  let(:cart_token) { cart.token }

  before(:each) do |data|
    login_as(user, scope: :user) if data.metadata[:response][:code] != '401'
  end

  path '/cart.json' do
    get 'show cart' do
      tags 'Cart'
      consumes 'application/json'

      response '200', 'Get cart content' do
        examples 'application/json': {
          success: true,
          id: 18,
          token: '4b6d91fe-ccb2-4d15-820f-8d563dabc635',
          items: [
            {
              id: 34,
              name: 'Decred',
              price: '1.11',
              quantity: 3
            },
            {
              id: 35,
              name: 'Monero',
              price: '8.27',
              quantity: 1
            }
          ],
          total_price: '11.6'
        }

        it ',should get current_cart content' do |example|
        end
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/definitions/unauthorized_body'
        run_test!
      end
    end
  end

  path '/cart/{cart_token}.json' do
    get 'show cart' do
      tags 'Cart'
      consumes 'application/json'
      parameter in: :path, name: 'cart_token', type: :string, required: true, description: 'Cart Token.'

      response '200', 'Get cart content' do
        examples 'application/json': {
          success: true,
          id: 18,
          token: '4b6d91fe-ccb2-4d15-820f-8d563dabc635',
          items: [
            {
              id: 34,
              name: 'Decred',
              price: '1.11',
              quantity: 3
            },
            {
              id: 35,
              name: 'Monero',
              price: '8.27',
              quantity: 1
            }
          ],
          total_price: '11.6'
        }

        it ',should get current_cart content' do |example|
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expected_result = {
            success: true,
            id: cart.id,
            token: cart.token,
            items: [
              {
                id: product.id,
                name: 'product',
                price: '50.0',
                quantity: 3
              },
              {
                id: 2,
                name: 'luna',
                price: '100.0',
                quantity: 2
              }
            ],
            total_price: '350.0'
          }
          expect(response_body).to eq(expected_result.as_json)
        end

        response '401', 'Unauthorized' do
          schema '$ref': '#/definitions/unauthorized_body'
          run_test!
        end
      end
    end
  end

  path '/cart/item.json' do
    post 'add product to cart' do
      tags 'Cart'
      consumes 'application/json'
      parameter in: :body, name: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string, example: 1 },
          quantity: { type: :integer, example: 10 }
        }
      }
      let(:body) { @body }

      response '200', 'Add product to cart' do
        it ',add new product to cart' do |example|
          @body = { product_id: ust.id, quantity: 3 }
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expect(cart.cart_items[ust.id.to_s]).to eq(3)
          expect(response_body).to eq({ success: true, message: '成功加入購物車' }.as_json)
        end

        it ',add the product which already exist in the cart' do |example|
          @body = { product_id: luna.id, quantity: 5 }
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expect(cart.cart_items[luna.id.to_s]).to eq(7)
          expect(response_body).to eq({ success: true, message: '成功加入購物車' }.as_json)
        end

        response '401', 'Unauthorized' do
          schema '$ref': '#/definitions/unauthorized_body'
          run_test!
        end
      end

      response '422', 'UnprocessableEntity' do
        it ', lack of inventory' do |example|
          @body = { product_id: product.id, quantity: 20 }
          submit_request(example.metadata)
          expect(response.status).to eq(422)
          response_body = JSON.parse(response.body)

          expect(cart.cart_items[product.id.to_s]).to eq(3)
          expect(response_body).to eq({ success: false, error: '該商品庫存不足' }.as_json)
        end
      end
    end

    delete 'remove product from cart' do
      tags 'Cart'
      consumes 'application/json'
      parameter in: :body, name: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string, example: 1 }
        }
      }
      let(:body) { @body }

      response '200', 'Remove product from cart' do
        it ',remove a product from cart' do |example|
          @body = { product_id: luna.id }
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expect(cart.cart_items[luna.id.to_s]).to be(nil)
          expect(response_body).to eq({ success: true, message: '已移除' }.as_json)
        end

        response '401', 'Unauthorized' do
          schema '$ref': '#/definitions/unauthorized_body'
          run_test!
        end
      end
    end
  end
end
