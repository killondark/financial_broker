# Создаются 2 пользователя
sasha = User.find_or_create_by!(email: 'sasha@email.com') do |u|
  u.name = 'Sasha'
end

anna = User.find_or_create_by!(email: 'anna@email.com') do |u|
  u.name = 'Anna'
end

# Создаются счета для этих пользователей
Account.find_or_create_by!(user: sasha) do |a|
  a.balance = 100.00
end

Account.find_or_create_by!(user: anna) do |a|
  a.balance = 0.00
end

# Создаются заказы для данных пользователей
sasha_order = Orders::Creator.new(user: sasha, order_params: { description: "Sasha's order description" }).call.value!
anna_order = Orders::Creator.new(user: anna, order_params: { description: "Anna's order description" }).call.value!

# Пользователь sasha переводит пользователю anna 9.99
Orders::Completer.new(
  order: sasha_order,
  account_from: sasha.account,
  account_to: anna.account,
  amount: 9.99
).call

# Пользователь anna переводит пользователю sasha 0.99
Orders::Completer.new(
  order: anna_order,
  account_from: anna.account,
  account_to: sasha.account,
  amount: 0.99
).call

# Пользователь anna сторнирует транзакции в заказе anna_order
Orders::Canceler.new(order: anna_order).call
