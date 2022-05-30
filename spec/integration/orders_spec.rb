require './spec/swagger_helper'

describe('Order API') do
  include Warden::Test::Helpers

  # for rswag CSRFToken security
  let(:Authorization) {}

  let(:user) { FactoryBot.create(:user) }
  let(:product) { FactoryBot.create(:product) }
  let(:luna) { FactoryBot.create(:luna) }
  let(:ust) { FactoryBot.create(:ust) }

  let(:order) { FactoryBot.create(:order, user: user) }
  let(:order_item_luna) { FactoryBot.create(:order_item, order: order, product: luna, price: luna.price, quantity: 1) }
  let(:order_item_ust) { FactoryBot.create(:order_item, order: order, product: ust, price: ust.price, quantity: 2) }


  before(:each) do |data|
    login_as(user, scope: :user) if data.metadata[:response][:code] != '401'
  end

  path '/orders.json' do
    get 'show orders' do
      tags 'Order'
      consumes 'application/json'
      security [CSRFToken: []]

      response '200', 'Success' do
        examples 'application/json': {
          success: true,
          orders: [
            {
              id: 8,
              user_id: 1,
              total_price: '3.33',
              token: '17fc18a3-4678-4f6f-824e-2b23cf52cc1c',
              name: '#1653835817',
              created_at: '2022-05-29T22:50:17.018+08:00',
              updated_at: '2022-05-29T22:50:17.018+08:00'
            },
          ],
        }

        let(:user_jimmy) { FactoryBot.create(:user, email: 'jimmy@myshop.com') }
        let!(:jimmy_order) { FactoryBot.create(:order, user: user_jimmy) }

        it ",should get current_user's orders" do |example|
          order
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expect(response_body['orders'].count).to eq(1)
          expect(response_body['orders'].first['user_id']).to eq(user.id)
        end
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/definitions/unauthorized_body'
        run_test!
      end
    end

    post 'Create an order' do
      tags 'Order'
      consumes 'application/json'
      security [CSRFToken: []]

      response '302', 'Success and Redirect to order page' do
        it ', should create an order and redirect' do |example|
          items = {}
          items[product.id.to_s] = 3
          items[luna.id.to_s] = 2
          cart = FactoryBot.create(:cart, user: user, items_hash: items.to_json)
          submit_request(example.metadata)
          expect(response.status).to eq(302)
          
          target_order = user.reload.orders.first
          expected_total_price = cart.total_price
          expected_order_items = [
            {
              name: product.name,
              price: product.price,
              quantity: 3,
            },
            {
              name: luna.name,
              price: luna.price,
              quantity: 2,
            },
          ].as_json

          expect(product.reload.inventory).to eq(7)
          expect(luna.reload.inventory).to eq(8)
          expect(user.orders.count).to eq(1)
          expect(target_order.order_items.as_json(only: %i[name price quantity]).as_json).to match(expected_order_items)
          expect(target_order.total_price).to eq(expected_total_price)
          expect(user.cart).to be(nil)
        end
      end

      response '422', 'UnprocessableEntity' do
        let(:sold_out_product) { FactoryBot.create(:product, :sold_out, name: 'sold_out_product') }

        it ', lack of inventory' do |example|
          items = {}
          items[sold_out_product.id.to_s] = 3
          FactoryBot.create(:cart, user: user, items_hash: items.to_json)

          submit_request(example.metadata)
          expect(response.status).to eq(422)
          response_body = JSON.parse(response.body)

          expect(response_body['success']).to be(false)
          expect(response_body['error']).to eq("商品 sold_out_product 的庫存不足。")
        end

        it ', no products in cart' do |example|
          FactoryBot.create(:cart, user: user, items_hash: {}.to_json)

          submit_request(example.metadata)
          expect(response.status).to eq(422)
          response_body = JSON.parse(response.body)

          expect(response_body['success']).to be(false)
          expect(response_body['error']).to eq('購物車中沒有商品')
        end
      end
    end
  end

  path '/orders/{order_token}.json' do
    get 'show order' do
      tags 'Order'
      consumes 'application/json'
      security [CSRFToken: []]
      parameter in: :path, name: 'order_token', type: :string, required: true, description: 'Order Token.'

      let(:order_token) { order.token }

      before(:each) do
        order_item_luna
        order_item_ust
      end

      response '200', 'Success' do
        examples 'application/json': {
          success: true,
          id: 8,
          user_id: 1,
          total_price: '3.33',
          token: '17fc18a3-4678-4f6f-824e-2b23cf52cc1c',
          name: '#1653835817',
          created_at: '2022-05-29T22:50:17.018+08:00',
          updated_at: '2022-05-29T22:50:17.018+08:00',
          order_items: [
            {
              id: 8,
              order_id: 8,
              product_id: 34,
              name: 'Decred',
              price: '1.11',
              quantity: 3,
              created_at: '2022-05-29T22:50:17.020+08:00',
              updated_at: '2022-05-29T22:50:17.020+08:00'
            }
          ]
        }

        it ',should get order content' do |example|
          submit_request(example.metadata)
          expect(response.status).to eq(200)
          response_body = JSON.parse(response.body)

          expect(response_body['token']).to eq(order.token)
          expect(response_body['id']).to eq(order.id)
          expect(response_body['order_items'].map { |item| item['product_id'] }).to match([luna.id, ust.id])
        end
      end

      response '422', 'UnprocessableEntity' do
        let(:order_token) { 'invalid_token' }

        it ',should get Order Not Found' do |example|
          submit_request(example.metadata)
          expect(response.status).to eq(422)
          response_body = JSON.parse(response.body)

          expect(response_body['success']).to be(false)
          expect(response_body['error']).to eq('Order Not Found')
        end
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/definitions/unauthorized_body'
        run_test!
      end
    end
  end
end
