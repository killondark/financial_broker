module Orders
  class Creator < ApplicationInteractor
    option :user, reader: :private
    option :order_params, reader: :private

    def call
      return Failure('User not found') unless user.is_a?(User)

      process_error do
        order = user.orders.create(order_params)

        if order.valid?
          Success(order)
        else
          Failure(order.errors.messages)
        end
      end
    end
  end
end
