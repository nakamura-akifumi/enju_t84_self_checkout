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
    unless %w(cardid2userid cardid2userbascket add_checkout_item checkout checkin getitem).include?(params['event'])
      logger.info("error: event error [unknown event] (#{params['event']})")
      @results = {status: 400, errors: [{status: 402, message: 'unknown event'}]}
      render :json => @results
      return
    end

    case params['event']
    when 'cardid2userid', 'cardid2userbascket'
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

      if params['event'] == 'cardid2userbascket'
        # create new bascket
        # TODO: slow!
        c = EnjuAdapter.new
        basket_id = c.get_checkout_basket(@card.user.profile.user_number)
        @results['results'][0]['basket_id'] = basket_id
        @results['results'][0]['session_value'] = c.cookie_value

      end

      render :json => @results
      return

    when 'add_checkout_item'
      if params[:basket_id].blank?
        @results = {status: 400, errors: [{status: 570, message: 'no basket_id'}]}
        render :json => @results
        return
      end

      basket = Basket.find(params[:basket_id])
      basket_id = basket.id

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

      item_identifier = item.item_identifier

      if params[:session_value].blank?
        @results = {status: 400, errors: [{status: 523, message: 'no session_value'}]}
        render :json => @results
        return
      end
      session_value = params[:session_value]

      c = EnjuAdapter.new
      result = c.add_checkout_item(session_value, basket_id, item_identifier)

      logger.debug "@@9-1 add_checkout_item status"
      logger.debug result.status
      logger.debug "@@9-2 add_checkout_item status"
      logger.debug result.body

      if result.status == 422
        error_msgs = JSON.parse(result.body)
        msg = error_msgs['base'][0]
        @results = {status: 422, errors: [{status: 422, message: msg}]}

        render :json => @results
        return
      end

      @checked_items = CheckedItem.where(basket_id: basket_id).order('id desc')
      @result_checked_items = []
      @checked_items.each do |checked_item|
        item = {}
        item['name'] = checked_item.item.manifestation.original_title
        item['item_identifier'] = checked_item.item.item_identifier
        item['due_date'] = checked_item.due_date.strftime('%Y/%m/%d')
        @result_checked_items << item
      end

      @results = {}
      @results['status'] = 200
      @results['results'] = {'status' => 'ok', 'items' => @result_checked_items}

      render :json => @results
      return

    when 'checkout'
      if params[:session_value].blank?
        @results = {status: 400, errors: [{status: 520, message: 'no session_value'}]}
        render :json => @results
        return
      end

      if params[:basket_id].blank?
        @results = {status: 400, errors: [{status: 522, message: 'no basket_id'}]}
        render :json => @results
        return
      end

      c = EnjuAdapter.new
      c.checkout(params[:session_value], params[:basket_id])

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
