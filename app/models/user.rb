class User < ApplicationRecord
  # TODO: в дальнейшем можно заменить на has_many :accounts,
  # добавив разноволютные или несколько счетов с одной валютой.
  has_one :account, dependent: :destroy
  has_many :orders, dependent: :destroy
end
