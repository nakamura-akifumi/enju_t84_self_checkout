class IdCardImportFileJob < ActiveJob::Base
  queue_as :enju_leaf

  def perform(id_card_import_file)
    id_card_import_file.import_start
  end
end