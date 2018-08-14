class IdCardsController < ApplicationController
  before_action :set_id_card, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  skip_after_action :verify_authorized, only: [:translate]

  protect_from_forgery :except => [:translate]

  # POST /t
  def translate
    @status = 200

    # check cert string
    if params['cert'].blank?
      logger.info("error: no cert")
      @results = {status: 400, errors: [{status: 400, message: 'no cert'}]}
      render :json => @results
      return
    end

    # action
    if params['event'].blank?
      logger.info("error: no event")
      @results = {status: 400, errors: [{status: 401, message: 'no event'}]}
      render :json => @results
      return
    end
    unless %w(cardid2userid checkout checkin getitem).include?(params['event'])
      logger.info("error: event error [unknown event] (#{params['event']})")
      @results = {status: 400, errors: [{status: 402, message: 'unknown event'}]}
      render :json => @results
      return
    end

    case params['event']
    when 'cardid2userid'
      if params[:tag].blank?
        @results = {status: 400, errors: [{status: 500, message: 'no tag'}]}
        render :json => @results
        return
      end

      @card = IdCard.where(card_id: params[:tag]).first
      if @card.blank?
        @results = {status: 400, errors: [{status: 501, message: 'invalid tag'}]}
        render :json => @results
        return
      end

      @results = {}
      @results['status'] = 200
      @results['results'] = [{
            'user_id' => @card.user.id,
            'user_number' => @card.user.profile.user_number,
            'name' => @card.user_name,
      }]
      render :json => @results
      return

    when 'getitem'
      if params[:item_identifier].blank?
        @results = {status: 400, errors: [{status: 510, message: 'no item_identifier'}]}
        render :json => @results
        return
      end

      item = Item.where(item_identifier: params[:item_identifier]).first
      if item.blank?
        @results = {status: 400, errors: [{status: 513, message: 'invalid item_identifier'}]}
        render :json => @results
        return
      end

      @results = {status: 200, item: {title: item.manifestation.title}}
      render :json => @results
      return

    when 'get_checkout_basket'
      if params[:user_number].blank?
        @results = {status: 400, errors: [{status: 520, message: 'no user_number'}]}
        render :json => @results
        return
      end

      profile = Profile.where(user_number: params[:user_number]).first
      if profile.blank?
        @results = {status: 400, errors: [{status: 521, message: 'invalid user_number'}]}
        render :json => @results
        return
      end

      c = EnjuAdapter.new
      res = c.get_checkout_basket(user_number)
      puts res

    when 'add_checkout_item'
      if params[:user_number].blank?
        @results = {status: 400, errors: [{status: 520, message: 'no user_number'}]}
        render :json => @results
        return
      end

      profile = Profile.where(user_number: params[:user_number]).first
      if profile.blank?
        @results = {status: 400, errors: [{status: 521, message: 'invalid user_number'}]}
        render :json => @results
        return
      end

      if params[:item_identifier].blank?
        @results = {status: 400, errors: [{status: 522, message: 'no item_identifier'}]}
        render :json => @results
        return
      end

      item = Item.where(item_identifier: params[:item_identifier]).first
      if item.blank?
        @results = {status: 400, errors: [{status: 523, message: 'invalid item_identifier'}]}
        render :json => @results
        return
      end

      user_number = profile.user_number
      item_identifier = item.item_identifier

      c = EnjuAdapter.new
      c.add_checkout_item(user_number, item_identifier)

    when 'checkout'
      if params[:user_number].blank?
        @results = {status: 400, errors: [{status: 520, message: 'no user_number'}]}
        render :json => @results
        return
      end

      profile = Profile.where(user_number: params[:user_number]).first
      if profile.blank?
        @results = {status: 400, errors: [{status: 521, message: 'invalid user_number'}]}
        render :json => @results
        return
      end

      if params[:item_identifier].blank?
        @results = {status: 400, errors: [{status: 522, message: 'no item_identifier'}]}
        render :json => @results
        return
      end

      item = Item.where(item_identifier: params[:item_identifier]).first
      if item.blank?
        @results = {status: 400, errors: [{status: 523, message: 'invalid item_identifier'}]}
        render :json => @results
        return
      end

      user_number = profile.user_number
      item_identifier = item.item_identifier

      c = EnjuAdapter.new
      c.checkout(user_number, item_identifier)

      @results = {status: 200}
      render :json => @results
      return


    when 'checkin'

      if params[:item_identifier].blank?
        @results = {status: 400, errors: [{status: 622, message: 'no item_identifier'}]}
        render :json => @results
        return
      end

      item = Item.where(item_identifier: params[:item_identifier]).first
      if item.blank?
        @results = {status: 400, errors: [{status: 623, message: 'invalid item_identifier'}]}
        render :json => @results
        return
      end

      c = EnjuAdapter.new
      r = c.checkin(item.item_identifier)

      @results = {status: 200}
      render :json => @results
      return

    end
  end

  # GET /self_iccards
  def index

    sort = {sort_by: 'card_id', order: 'asc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'user_name'
    end
    sort[:order] = 'asc' if params[:order] == 'asc'

    search = IdCard.search
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.build do
        fulltext query
      end
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, IdCard.default_per_page)
    @id_cards = search.execute!.results

    @users = card_users
  end

  # GET /id_cards/1
  def show
  end

  # GET /id_cards/new
  def new
    @id_card = IdCard.new
    @users = card_users
  end

  # GET /id_cards/1/edit
  def edit
    @users = card_users
  end

  # POST /id_cards
  def create
    @id_card = IdCard.new(id_card_params)

    if @id_card.save
      redirect_to @id_card, notice: t('controller.successfully_created', model: t('activerecord.models.id_card'))
    else
      @users = card_users
      render :new
    end
  end

  # PATCH/PUT /self_iccards/1
  def update
    if @id_card.update(id_card_params)
      redirect_to @id_card, notice: t('controller.successfully_updated', model: t('activerecord.models.id_card'))
    else
      render :edit
    end
  end

  # DELETE /self_iccards/1
  def destroy
    @id_card.destroy
    redirect_to self_id_cards_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.id_card'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_id_card
      @id_card = IdCard.find(params[:id])
      authorize @id_card
    end

    def check_policy
      authorize IdCard
    end

    # Only allow a trusted parameter "white list" through.
    def id_card_params
      params.require(:id_card).permit(:card_id, :user_id)
    end

    def card_users
      users = User.all.inject([]) do |arr, u|
        arr << [(u.profile.full_name.blank?)?(u.username):(u.profile.full_name), u.id]
        arr
      end

      users
    end
end
