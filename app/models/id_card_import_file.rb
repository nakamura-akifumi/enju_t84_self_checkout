class IdCardImportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  include ImportFile

  default_scope {order('id_card_import_files.id DESC')}
  scope :not_imported, -> { in_state(:pending) }

  has_attached_file :id_card_import,
                    path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"

  validates_attachment_content_type :id_card_import, content_type: [
      'text/csv',
      'text/plain',
      'text/tab-separated-values',
      'application/octet-stream',
      'application/vnd.ms-excel'
  ]
  validates_attachment_presence :id_card_import
  belongs_to :user, validate: true
  has_many :id_card_import_results
  has_many :id_card_import_file_transitions, autosave: false

  attr_accessor :mode

  def state_machine
    IdCardImportFileStateMachine.new(self, transition_class: IdCardImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  # 未処理のインポート作業用のファイルを一括で処理します。
  def self.import
    IdCardImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    Rails.logger.info "#{Time.zone.now} importing resources failed!"
  end

  # 利用者情報をTSVファイルを用いて作成します。
  def import
    transition_to!(:started)
    num = { card_found: 0, id_card_imported: 0, user_found: 0, failed: 0, error: 0 }
    rows = open_import_file(create_import_temp_file(id_card_import))
    row_num = 1

    field = rows.first

    if [field['card_id']].reject{ |f| f.to_s.strip == "" }.empty?
      raise "card_id column is not found"
    end

    rows.each do |row|

      logger.info "row:"
      logger.info row

      row_num += 1
      import_result = IdCardImportResult.create!(
          id_card_import_file_id: id, body: row.fields.join("\t")
      )
      next if row['dummy'].to_s.strip.present?

      card_id = row['card_id']

      new_card = SelfIccard.where(card_id: card_id).first
      if new_card
        #import_result.user = new_user
        import_result.save
        num[:card_found] += 1
      else
        new_card = SelfIccard.new
        new_card.card_id = card_id
        profile = Profile.where(user_number: row['user_number']).first
        unless profile
          logger.debug "unless profile: #{row['user_number']}"
          num[:failed] += 1
          next
        else
          new_card.user = profile.user

          SelfIccard.transaction do
            if new_card.valid?
              logger.debug "new_card valid"
              new_card.save!
              import_result.self_iccard = new_card
              import_result.save!
              num[:id_card_imported] += 1
            else
              logger.debug "new_card invalid"
              error_message = "line #{row_num}: "
              error_message += new_card.errors.full_messages.join(" ")
              import_result.error_message = error_message
              import_result.save
              num[:error] += 1
              logger.debug "error_message: #{error_message}"
            end
          end
        end
      end
    end

    Sunspot.commit
    rows.close
    error_messages = id_card_import_results.order(:id).pluck(:error_message).compact
    unless error_messages.empty?
      self.error_message = '' if self.error_message.nil?
      self.error_message += "\n"
      self.error_message += error_messages.join("\n")
    end
    save
    if num[:error] >= 1
      transition_to!(:failed)
    else
      transition_to!(:completed)
    end
    send_message
    num
  rescue => e
    Rails.logger.warn(e)
    transition_to!(:failed)
    raise e
  end

  def open_import_file(tempfile)
    file = CSV.open(tempfile.path, 'r:utf-8', col_sep: "\t")
    header_columns = %w(
      card_id username user_number
    )

    header = file.first
    ignored_columns = header - header_columns
    unless ignored_columns.empty?
      self.error_message = I18n.t('import.following_column_were_ignored', column: ignored_columns.join(', '))
      save!
    end
    rows = CSV.open(tempfile.path, 'r:utf-8', headers: header, col_sep: "\t")
    IdCardImportResult.create!(id_card_import_file_id: id, body: header.join("\t"))
    tempfile.close(true)
    file.close
    rows
  end

end
