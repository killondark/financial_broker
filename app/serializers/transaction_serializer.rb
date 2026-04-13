class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :account_id, :order_id, :amount, :reversed_at, :frozen_at

  def amount
    object.amount.to_s
  end
end
