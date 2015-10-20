class Api::V1::InventoryItemsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      items = @store.inventory_items.inactive if params[:inactive] == true
      items ||= @store.inventory_items.active
      render json: prepare_json(items.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def show
    begin
      item = @store.inventory_items.find(params[:id])
      render json: prepare_json(item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def update
    begin
      item = @store.inventory_items.find(params[:id])
      item.update!(inventory_item_params)
      render json: prepare_json(item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def inventory_item_params
    # To record purchase, use medicine update path since med batch call back after_create will cover purchase creation
    params.require(:inventory_item).permit(:amount, :status,
                                           med_batch_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                                  :store_id, :amount_per_pkg, :amount_unit, :total_units,
                                                                  :total_price, :user_id, :category_id],
                                           sale_price_attributes: [:id, :amount, :discount],
                                           sales_attributes: [:amount, :delivery_time, :due_date, :paid, :performed,
                                                              :sale_user_id, :seller_id, :buyer_id, :seller_id, :seller_item_id, :total_price])
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end