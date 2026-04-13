class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :description, :status, :created_at, :updated_at
  has_many :transactions
end
