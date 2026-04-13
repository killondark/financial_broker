class Order < ApplicationRecord
  belongs_to :user
  has_many :transactions

  enum :status, { created: 0, completed: 1, cancelled: 2 }, default: :created
end
