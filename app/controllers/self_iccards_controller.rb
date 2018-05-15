class SelfIccardsController < ApplicationController
  before_action :set_self_iccard, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /self_iccards
  def index

    sort = {sort_by: 'card_id', order: 'asc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'user_name'
    end
    sort[:order] = 'asc' if params[:order] == 'asc'

    search = SelfIccard.search
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.build do
        fulltext query
      end
    end
=begin
    search.build do
      order_by sort[:sort_by], sort[:order]
    end
=end
    page = params[:page] || 1
    search.query.paginate(page.to_i, SelfIccard.default_per_page)
    @self_iccards = search.execute!.results

    @users = card_users
  end

  # GET /self_iccards/1
  def show
  end

  # GET /self_iccards/new
  def new
    @self_iccard = SelfIccard.new
    @users = card_users
  end

  # GET /self_iccards/1/edit
  def edit
    @users = card_users
  end

  # POST /self_iccards
  def create
    @self_iccard = SelfIccard.new(self_iccard_params)

    if @self_iccard.save
      redirect_to @self_iccard, notice: t('controller.successfully_created', model: t('activerecord.models.self_iccard'))
    else
      @users = card_users
      render :new
    end
  end

  # PATCH/PUT /self_iccards/1
  def update
    if @self_iccard.update(self_iccard_params)
      redirect_to @self_iccard, notice: t('controller.successfully_updated', model: t('activerecord.models.self_iccard'))
    else
      render :edit
    end
  end

  # DELETE /self_iccards/1
  def destroy
    @self_iccard.destroy
    redirect_to self_iccards_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.self_iccard'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_self_iccard
      @self_iccard = SelfIccard.find(params[:id])
      authorize @self_iccard
    end

    def check_policy
      authorize SelfIccard
    end

    # Only allow a trusted parameter "white list" through.
    def self_iccard_params
      params.require(:self_iccard).permit(:card_id, :user_id)
    end

    def card_users
      users = User.all.inject([]) do |arr, u|
        arr << [(u.profile.full_name.blank?)?(u.username):(u.profile.full_name), u.id]
        arr
      end

      users
    end
end
