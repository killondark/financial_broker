class Transaction < ApplicationRecord
  INVALID_AMOUNT = 0.0

  belongs_to :account
  belongs_to :order
end
