class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, foreign_key: true
      t.string :stripe_customer_id
      t.boolean :active, null: false, default: false
      t.boolean :billing_issue, null: false, default: false

      t.timestamps
    end
  end
end
