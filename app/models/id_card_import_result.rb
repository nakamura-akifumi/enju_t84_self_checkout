class IdCardImportResult < ActiveRecord::Base
  scope :file_id, proc{ |file_id| where(id_card_import_file_id: file_id) }
  scope :failed, -> { where(user_id: nil) }

  belongs_to :id_card_import_file
  belongs_to :user
  belongs_to :self_iccard
end