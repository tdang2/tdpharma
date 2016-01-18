class Api::V1::ReceiptsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      receipts = @store.receipts.purchase_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:purchase]
      receipts = @store.receipts.sale_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:sale]
      receipts = @store.receipts.adjustment_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:adjustment]
      receipts ||= @store.receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}])
      receipts = receipts.created_after(params[:before]) if params[:before]
      receipts = receipts.created_before(params[:end]) if params[:end]
      render json: prepare_json(receipts.as_json(include: {:transactions => {include: [{seller_item: {include: :itemable}},
                                                                                       buyer_item: {include: :itemable},
                                                                                       adjust_item: {include: :itemable}]}}
                                )), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def create
    begin
      receipt = @store.receipts.create!(receipt_params)
      render json: prepare_json(receipt.as_json(include: {:transactions => {include: [{seller_item: {include: :itemable}},
                                                                                      buyer_item: {include: :itemable},
                                                                                      adjust_item: {include: :itemable}]}}
                                )), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def receipt_params
    params.require(:receipt).permit(:receipt_type, :total, :store_id,
                                    med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :store_id,
                                                             :amount_per_pkg, :amount_unit, :total_units, :total_price,
                                                             :user_id, :category_id, :paid, :medicine_id, :inventory_item_id],
                                    transactions_attributes: [:amount, :delivery_time, :due_date, :paid, :performed, :seller_id, :buyer_id,
                                                              :sale_user_id, :seller_item_id, :purchase_user_id, :buyer_item_id,
                                                              :adjust_item_id, :adjust_user_id, :adjust_store_id, :transaction_type, :total_price])
  end

  def get_store
    @store = @current_user.store if @current_user
  end

end
