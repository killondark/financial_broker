RSpec.describe '/api/user/orders', :api, type: :request do
  let(:user) { create(:user) }

  describe 'GET /api/users/:id/orders' do
    subject(:orders_response) do
      get api_orders_path(user)
      response
    end

    it 'returns empty lists of orders' do
      aggregate_failures do
        expect(orders_response).to have_http_status(:success)
        expect(response_body_to_json).to eq([])
      end
    end

    context 'when orders are exists' do
      let(:user) { create(:user, :with_orders) }

      let(:order) { user.orders.first }

      it 'returns lists of orders' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:success)
          expect(response_body_to_json).to eq(
            [
              {
                id: order.id,
                status: order.status,
                description: order.description,
                user_id: order.user_id,
                created_at: order.created_at.iso8601(3),
                updated_at: order.updated_at.iso8601(3),
                transactions: []
              }
            ]
          )
        end
      end
    end
  end

  describe 'GET /api/users/:id/orders/:order_id' do
    subject(:orders_response) do
      get api_order_path(user, order)
      response
    end

    let(:order) { 'empty' }

    it 'returns not_found status if order not found' do
      expect(orders_response).to have_http_status(:not_found)
    end

    context 'when the user and order are found' do
      let(:user) { create(:user, :with_orders) }
      let(:order) { user.orders.first }

      it 'returns order and success status' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:success)
          expect(response_body_to_json).to eq(
            {
              id: order.id,
              status: order.status,
              description: order.description,
              user_id: order.user_id,
              created_at: order.created_at.iso8601(3),
              updated_at: order.updated_at.iso8601(3),
              transactions: []
            }
          )
        end
      end
    end
  end

  describe 'POST /api/users/:id/orders' do
    subject(:orders_response) do
      post api_orders_path(user), params: params
      response
    end

    let(:params) { { order: { description: 'Order description' } } }

    it 'returns created order' do
      aggregate_failures do
        expect(orders_response).to have_http_status(:success)
        expect(response_body_to_json).to include(
          {
            user_id: user.id,
            description: params[:order][:description],
            status: 'created',
            transactions: []
          }
        )
      end
    end

    context 'when user not found' do
      let(:user) { 'unexist id' }

      it 'returns error message and unprocessable_entity status' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:not_found)
          expect(response_body_to_json).to eq(errors: 'User not found')
        end
      end
    end
  end

  describe 'POST /api/users/:id/orders/:order_id/complete' do
    subject(:orders_response) do
      post complete_api_order_path(user, order), params: params
      response
    end

    let(:user) { create(:user, :with_orders, :with_account) }
    let(:user_to) { create(:user, :with_account) }
    let(:order) { user.orders.first }
    let(:amount) { 'amount' }
    let(:params) do
      {
        order: {
          account_from_id: user.account.id,
          account_to_id: user_to.account.id,
          amount: amount
        }
      }
    end

    it_behaves_like 'when amount incorrect message'

    context 'when amount is zero' do
      let(:amount) { 0.0 }

      it_behaves_like 'when amount incorrect message'
    end

    context 'when amount is less than zero' do
      let(:amount) { - 10.0 }

      it_behaves_like 'when amount incorrect message'
    end

    context 'when not enough money in the account_from' do
      let(:amount) { 10.0 }

      it 'returns not enough money message' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:unprocessable_entity)
          expect(response_body_to_json).to eq(errors: 'there is not enough money in the account_from')
        end
      end
    end

    context 'when impossible to complete operation done — status unless created' do
      let(:order) { create(:order, :status_completed, user: user) }

      it_behaves_like 'when order status unless created'
    end

    context 'when impossible to complete operation done — status unless created part 2' do
      let(:order) { create(:order, :status_cancelled, user: user) }

      it_behaves_like 'when order status unless created'
    end

    context 'when order changes from created to completed' do
      let(:amount) { 1.0 }

      before { user.account.update(balance: amount) }

      it 'returns order with completed status' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:success)
          transaction_from = user.account.transactions.first
          transaction_to = user_to.account.transactions.first
          transactions = [transaction_from, transaction_to].map do |t|
            {
              account_id: t.account_id,
              amount: t.amount.to_s,
              frozen_at: t.frozen_at,
              id: t.id,
              order_id: t.order_id,
              reversed_at: t.reversed_at&.iso8601(3)
            }
          end
          order = user.reload.orders.first
          expect(response_body_to_json).to eq(
            {
              id: order.id,
              status: 'completed',
              description: order.description,
              user_id: order.user_id,
              created_at: order.created_at.iso8601(3),
              updated_at: order.updated_at.iso8601(3),
              transactions: transactions
            }
          )
        end
      end
    end
  end

  describe 'POST /api/users/:id/orders/:order_id/cancel' do
    subject(:orders_response) do
      post cancel_api_order_path(user, order)
      response
    end

    let(:user) { create(:user, :with_orders, :with_account) }
    let(:user_to) { create(:user, :with_account) }
    let(:order) { user.orders.first }
    let(:amount) { 1.1 }

    before { order }

    it_behaves_like 'when order status unless completed'

    context 'when impossible to cancel operation done — status unless completed' do
      let(:user) { create(:user, :with_account) }
      let(:order) { create(:order, :status_cancelled, user: user) }

      it_behaves_like 'when order status unless completed'
    end

    context 'when order with completed status' do
      before do
        user.account.update(balance: amount)

        Orders::Completer.new(
          order: order,
          account_from: user.account,
          account_to: user_to.account,
          amount: amount
        ).call
      end

      it 'returns order with cancelled status' do
        aggregate_failures do
          expect(orders_response).to have_http_status(:success)
          transactions = Transaction.all.map do |t|
            {
              account_id: t.account_id,
              amount: t.amount.to_s,
              frozen_at: t.frozen_at,
              id: t.id,
              order_id: t.order_id,
              reversed_at: t.reversed_at&.iso8601(3)
            }
          end
          order = user.reload.orders.first
          expect(response_body_to_json).to eq(
            {
              id: order.id,
              status: 'cancelled',
              description: order.description,
              user_id: order.user_id,
              created_at: order.created_at.iso8601(3),
              updated_at: order.updated_at.iso8601(3),
              transactions: transactions
            }
          )
        end
      end

      context 'when not enough money in the account_to for cancel' do
        before do
          user_to.account.update(balance: 0.0)
        end

        it 'returns validation errors message' do
          aggregate_failures do
            expect(orders_response).to have_http_status(:unprocessable_entity)
            expect(response_body_to_json).to eq(errors: 'Validation failed: Balance must be greater than or equal to 0')
          end
        end
      end
    end
  end
end
