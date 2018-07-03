class CreateIdCardImportResults < ActiveRecord::Migration
  def change
    create_table :id_card_import_results do |t|
      t.references :id_card_import_file, index: true
      t.references :self_iccard, index: true
      t.text :body
      t.text :error_message

      t.timestamps
    end
  end
end
