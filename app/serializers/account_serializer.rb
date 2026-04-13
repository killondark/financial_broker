class AccountSerializer < ActiveModel::Serializer
  attributes :id, :balance

  def balance
    object.balance.to_s
  end
end
