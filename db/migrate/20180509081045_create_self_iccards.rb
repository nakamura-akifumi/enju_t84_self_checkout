class CreateSelfIccards < ActiveRecord::Migration
  def change
    create_table :self_iccards do |t|
      t.string :card_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
