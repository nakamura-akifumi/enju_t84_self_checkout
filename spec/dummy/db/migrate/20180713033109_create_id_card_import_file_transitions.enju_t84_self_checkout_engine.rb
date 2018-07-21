# This migration comes from enju_t84_self_checkout_engine (originally 20180629030441)
class CreateIdCardImportFileTransitions < ActiveRecord::Migration
  def change
    create_table :id_card_import_file_transitions do |t|
      t.string :to_state
      t.string :metadata
      t.integer :sort_key
      t.references :id_card_import_file
      t.boolean :most_recent, null: true
      t.timestamps
    end
  end
end
