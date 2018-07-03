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
