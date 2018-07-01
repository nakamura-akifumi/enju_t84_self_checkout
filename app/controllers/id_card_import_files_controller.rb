class IdCardImportFilesController < ApplicationController
  before_action :set_id_card_import_file, only: [:show, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  def index
    @id_card_import_files = IdCardImportFile.order(id: :desc).page(params[:page])
  end

  def new
    @id_card_import_file = IdCardImportFile.new

  end

  def create
    @id_card_import_file = IdCardImportFile.new(id_card_import_file_params)
    @id_card_import_file.user = current_user

    if @id_card_import_file.save
      if @id_card_import_file.mode == 'import'
        UserImportFileJob.perform_later(@id_card_import_file)
      end
      redirect_to @id_card_import_file, notice: t('import.successfully_created', model: t('activerecord.models.user_import_file'))
    else
      prepare_options
      render action: "new"
    end
  end

  def show
  end

  def destroy

  end

  private
  def check_policy
    authorize IdCardImportFile
  end

  def set_id_card_import_file
    @id_card_import_file = IdCardImportFile.find(params[:id])
    authorize @id_card_import_file
    #access_denied unless LibraryGroup.site_config.network_access_allowed?(request.ip)
  end

  def id_card_import_file_params
    params.require(:id_card_import_file).permit(
        :id_card_import, :edit_mode, :user_encoding, :mode
    )
  end

  def prepare_options
  end
end
