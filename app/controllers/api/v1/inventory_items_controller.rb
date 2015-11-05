class Api::V1::InventoryItemsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      render json: prepare_json({message: 'Current user has no associated store'}), status: 400 unless @store
      items = @store.inventory_items.inactive if params[:inactive] == true
      items ||= @store.inventory_items.active
      items = items.by_category(params[:category_id]) if params[:category_id]
      items = items.page(params[:page]) if params[:page]
      res = {
          items: items.page(params[:page]).as_json(include: [:itemable, :sale_price], methods: :photo_thumb),
          total_count: items.count
      }
      render json: prepare_json(res), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def show
    begin
      render json: prepare_json({message: 'Current user has no associated store'}), status: 400 unless @store
      item = @store.inventory_items.find(params[:id])
      render json: prepare_json(item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def update
    begin
      render json: prepare_json({message: 'Current user has no associated store'}), status: 400 unless @store
      item = @store.inventory_items.find(params[:id])
      item.update!(inventory_item_params)
      render json: prepare_json(item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def inventory_item_params
    params.require(:inventory_item).permit(:amount, :status,
                                           image_attributes: [:id, :photo],
                                           med_batch_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                                  :store_id, :amount_per_pkg, :amount_unit, :total_units,
                                                                  :total_price, :user_id, :category_id],
                                           sale_price_attributes: [:id, :amount, :discount])
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end