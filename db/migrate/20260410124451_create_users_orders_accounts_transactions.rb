class CreateUsersOrdersAccountsTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, index: { unique: true }
      t.timestamps
    end

    create_table :orders do |t|
      t.integer :status
      t.string :description
      t.belongs_to :user, null: false
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :user, null: false, default: 0.0
      t.decimal :balance, null: false, precision: 5, scale: 2
      t.timestamps
    end

    create_table :transactions do |t|
      t.belongs_to :account, null: false
      t.belongs_to :order, null: false
      t.decimal :amount, precision: 5, scale: 2
      t.datetime :reversed_at # TODO: поле для информации, что транзакция сторнирована(у order статус отменен)
      # TODO: данная колонка для возможность временно заморозить деньги на счете пользователя в размере amount
      # Целевое использование:
      # 1. Перевод денег user1.account -> user2.account
      # 2. Создаются 2 транзакции: для user1.account и для user2.account
      # 3. Средства в размере amount, находящиеся в user2.account, могут быть «заморожены» на время до frozen_at
      # Данный кейс может быть реализован для того, чтобы обеспечить необходимо-положительный остаток
      # на счете user2.account в случае сторнирования операции на user1.account в размере amount.
      t.datetime :frozen_at
      t.timestamps
    end
  end
end
