module Api
  class OrdersController < ApplicationController
    def index
      render json: orders, each_serializer: OrderSerializer
    end

    def show
      render json: order, serializer: OrderSerializer
    end

    def create
      interactor = Orders::Creator.new(user: user, order_params: order_params.to_h).call
      render_interactor_result(interactor, serializer: OrderSerializer)
    end

    def complete
      interactor = Orders::Completer.new(
        order: order,
        account_from: account_from,
        account_to: account_to,
        amount: params.dig(:order, :amount).to_d
      ).call
      render_interactor_result(interactor, serializer: OrderSerializer)
    end

    def cancel
      interactor = Orders::Canceler.new(order: order).call
      render_interactor_result(interactor, serializer: OrderSerializer)
    end

    private

    def order_params
      params.require(:order).permit(:description)
    end

    def order_complete_params
      params.require(:order).permit(:account_from_id, :account_to_id, :amount)
    end

    # TODO: поиск по user добавлено осознанно: orders должны принадлежать user
    def orders
      Order.where(user: user).includes(:user, :transactions)
    end

    def order
      orders.find(params[:order_id])
    end

    def user
      User.find(params[:id])
    end

    # TODO: поиск по user добавлено осознанно: account должен принадлежать user
    def account_from
      Account.where(user: user).find(params.dig(:order, :account_from_id))
    end

    def account_to
      Account.find(params.dig(:order, :account_to_id))
    end
  end
end
