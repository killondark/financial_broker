module Orders
  class Completer < ApplicationInteractor
    option :order, reader: :private
    option :account_from, reader: :private
    option :account_to, reader: :private
    option :amount, reader: :private

    def call
      return Failure('order not found') unless order.is_a?(Order)
      return Failure('account_from not found') unless account_from.is_a?(Account)
      return Failure('account_to not found') unless account_to.is_a?(Account)
      return Failure('amount is incorrect or less than or equal to zero') if amount <= Transaction::INVALID_AMOUNT
      if account_from.balance - amount < Transaction::INVALID_AMOUNT
        return Failure('there is not enough money in the account_from')
      end
      return Failure('impossible to complete the order in this status') unless order.created?

      process_error do
        ActiveRecord::Base.transaction do
          Transaction.create!(
            account: account_from,
            order: order,
            amount: - amount
          )
          account_from.update!(balance: account_from.balance - amount)

          Transaction.create!(
            account: account_to,
            order: order,
            amount: amount
          )
          account_to.update!(balance: account_to.balance + amount)

          order.update!(status: :completed)
        end

        Success(order.reload)
      end
    end
  end
end
