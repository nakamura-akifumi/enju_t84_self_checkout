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
        IdCardImportFileJob.perform_later(@id_card_import_file)
      end
      redirect_to @id_card_import_file, notice: t('import.successfully_created', model: t('activerecord.models.id_card_import_file'))
    else
      prepare_options
      render action: "new"
    end
  end

  def show
    if @id_card_import_file.id_card_import.path
      unless ENV['ENJU_STORAGE'] == 's3'
        file = @id_card_import_file.id_card_import.path
      end
    end
    @id_card_import_results = @id_card_import_file.id_card_import_results.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @id_card_import_file }
      format.download {
        if ENV['ENJU_STORAGE'] == 's3'
          send_data Faraday.get(@id_card_import_file.id_card_import.expiring_url).body.force_encoding('UTF-8'),
                    filename: File.basename(@id_card_import_file.id_card_import_file_name), type: 'application/octet-stream'
        else
          send_file file, filename: @id_card_import_file.id_card_import_file_name, type: 'application/octet-stream'
        end
      }
    end
  end

  def destroy
    @id_card_import_file.destroy
    redirect_to(id_card_import_files_url)
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
