module Api
  class UsersController < ApplicationController
    def index
      users = User.includes(:account, :orders).all
      render json: users, each_serializer: UserSerializer
    end

    def show
      user = User.includes(:account, :orders).find(params[:id])
      render json: user, serializer: UserSerializer
    end

    def create
      user = User.new(user_params)
      if user.save!
        render json: user, serializer: UserSerializer, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email)
    end
  end
end
