module Orders
  class Canceler < ApplicationInteractor
    option :order, reader: :private

    def call
      return Failure('order not found') unless order.is_a?(Order)
      return Failure('impossible to cancel the order in this status') unless order.completed?

      process_error do
        ActiveRecord::Base.transaction do
          order.transactions.includes(:account).each do |transaction|
            amount = - transaction.amount
            account = transaction.account

            Transaction.create!(
              account: transaction.account,
              order: order,
              amount: amount,
              reversed_at: Time.current
            )
            account.update!(balance: account.balance + amount)
          end

          order.update!(status: :cancelled)
        end

        Success(order.reload)
      end
    end
  end
end
