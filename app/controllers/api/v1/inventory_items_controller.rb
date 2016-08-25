class Api::V1::InventoryItemsController < ApplicationController
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store
  rescue_from StandardError, with: :render_error

  def render_error(e)
    NewRelic::Agent.notice_error(e) if Rails.env.production?
    render json: prepare_json({errors: e.message}), status: 400
  end

  def index
    unless @store
      render json: prepare_json({message: 'Current user has no associated store'}), status: 400
    else
      items = @store.inventory_items.order(:item_name)
      if params[:inventory_id]
        # Return the page that contains the inventory id
        position = items.map(&:id).index(params[:inventory_id].to_i) + 1
        params[:page] = (position.to_f/25).ceil
      else
        # Default pagination
        items = items.by_type(Medicine).where('medicines.name LIKE ?', "%#{params[:search].titleize}%") if params[:search]
        items = items.active if params[:active] == true
        items = items.inactive if params[:active] == false
        items = items.by_category(params[:category_id]) if params[:category_id]
      end
      res = {
          items: items.page(params[:page]).as_json(include: [:itemable, :sale_price, :category, :available_batches], methods: :photo_thumb),
          total_count: items.count,
          page: params[:page]
      }
      render json: prepare_json(res), status: 200
    end
  end

  def show
    render json: prepare_json({message: 'Current user has no associated store'}), status: 400 unless @store
    item = @store.inventory_items.includes(:itemable, :sale_price, :med_batches).find(params[:id])
    render_item(item)
  end

  def update
    render json: prepare_json({message: 'Current user has no associated store'}), status: 400 unless @store
    item = @store.inventory_items.find(params[:id])
    item.update!(inventory_item_params)
    render_item(item)
  end

  private
  def render_item(item)
    render json: prepare_json(item.as_json(include: [:itemable, :sale_price, :available_batches, {image: {methods: [:photo_thumb, :photo_medium]}}], methods: :photo_thumb)), status: 200
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:amount, :status,
                                           image_attributes: [:id, :photo],
                                           med_batch_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                                  :store_id, :amount_per_pkg, :number_pkg, :total_units,
                                                                  :total_price, :user_id, :category_id],
                                           sale_price_attributes: [:id, :amount, :discount])
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end