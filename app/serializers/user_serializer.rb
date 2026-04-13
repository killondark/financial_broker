class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
  has_one :account
  has_many :orders
end
