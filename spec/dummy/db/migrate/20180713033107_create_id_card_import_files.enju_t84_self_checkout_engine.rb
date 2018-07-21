# This migration comes from enju_t84_self_checkout_engine (originally 20180626123930)
class CreateIdCardImportFiles < ActiveRecord::Migration
  def change
    create_table :id_card_import_files do |t|
      t.references :user, foreign_key: true, null: false
      t.text :note
      t.datetime :executed_at
      t.string :id_card_import_file_name
      t.string :id_card_import_content_type
      t.integer :id_card_import_file_size
      t.datetime :id_card_import_updated_at
      t.string :id_card_import_fingerprint
      t.string :edit_mode
      t.text :error_message
      t.string :user_encoding

      t.timestamps null: false
    end
  end
end
