class IdCardImportFileTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :id_card_import_file, inverse_of: :id_card_import_file_transitions
end
