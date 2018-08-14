class RenameSelfIccardsToIdcards < ActiveRecord::Migration
  def change
    rename_table :self_iccards, :id_cards
  end
end
