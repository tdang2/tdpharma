class Api::V1::InventoryItemsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index

  end

  def create

  end

  def show

  end

  def create

  end

  def destroy

  end

  private
  def inventory_item_params
    # Med batch call back after create will cover purchase creation
    params.require(:inventory_item).permit(:amount, :status,
                                           med_batch_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                                  :store_id, :amount_per_pkg, :amount_unit, :total_units,
                                                                  :total_price, :user_id, :category_id],
                                           sales_attributes: [:amount, :delivery_time, :due_date, :paid, :performed,
                                                              :sale_user_id, :seller_id, :buyer_id, :seller_id, :seller_item_id, :total_price])
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end