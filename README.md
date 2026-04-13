# Financial broker

Реализовано MVP под запрос.

**Технические требования:**

* Ruby version `"3.3.1"`

**Для запуска приложения:**
- склонировать/скопировать локально данный репозиторий
- запустить `bundle install` в папке с проектом
- создать базы данных: `rails db:create`
- запустить миграции `rails db:migrate`
- наполнить базу данных `rails db:seed`(опционально)
- запустить `rails s`

**Для запуска rspec-тестов:**
- `bundle exec rspec` \
Написал интеграционные тесты `spec/requests/api/orders_spec.rb` на осовную на данный момент бизнес-логику.
В них подробно расписаны все требуемые кейсы.  \
Тесты на `users-CRUD`(`app/controllers/api/users_controller.rb`) были пропущены для экономии времени.

**Роуты:**
```text
complete_api_order POST /api/users/:id/orders/:order_id/complete     api/orders#complete
  cancel_api_order POST /api/users/:id/orders/:order_id/cancel       api/orders#cancel
        api_orders GET  /api/users/:id/orders                        api/orders#index
                   POST /api/users/:id/orders                        api/orders#create
         api_order GET  /api/users/:id/orders/:order_id              api/orders#show
         api_users GET  /api/users                                   api/users#index
                   POST /api/users                                   api/users#create
          api_user GET  /api/users/:id                               api/users#show
```

**Примеры работы:**
```ruby
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
sasha_order = Orders::Creator.new(
  user: sasha, order_params: { description: "Sasha's order description" }
).call.value!

anna_order = Orders::Creator.new(
  user: anna, order_params: { description: "Anna's order description" }
).call.value!

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
```
В коде встречаются `TODO:`. Там расписал возможные точки для роста, причину принятия того или иного решения.