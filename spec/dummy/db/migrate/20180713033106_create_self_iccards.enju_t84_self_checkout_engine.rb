# This migration comes from enju_t84_self_checkout_engine (originally 20180509081045)
class CreateSelfIccards < ActiveRecord::Migration
  def change
    create_table :self_iccards do |t|
      t.string :card_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
