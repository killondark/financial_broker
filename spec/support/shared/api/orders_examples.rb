shared_examples 'when amount incorrect message' do
  it 'returns amount incorrect message and unprocessable_entity status' do
    aggregate_failures do
      expect(orders_response).to have_http_status(:unprocessable_entity)
      expect(response_body_to_json).to eq(errors: 'amount is incorrect or less than or equal to zero')
    end
  end
end

shared_examples 'when order status unless created' do
  let(:user) { create(:user, :with_account) }
  let(:amount) { 1.0 }

  before do
    # order
    user.account.update(balance: amount)
  end

  it 'returns impossible to complete message' do
    aggregate_failures do
      expect(orders_response).to have_http_status(:unprocessable_entity)
      expect(response_body_to_json).to eq(errors: 'impossible to complete the order in this status')
    end
  end
end

shared_examples 'when order status unless completed' do
  it 'returns impossible to cancel message and unprocessable_entity status' do
    aggregate_failures do
      expect(orders_response).to have_http_status(:unprocessable_entity)
      expect(response_body_to_json).to eq(errors: 'impossible to cancel the order in this status')
    end
  end
end
