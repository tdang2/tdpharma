class Api::V1::ReceiptsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store
  rescue_from StandardError, with: :render_error

  def render_error(e)
    NewRelic::Agent.notice_error(e) if Rails.env.production?
    render json: prepare_json({errors: e.message}), status: 400
  end

  def index
    receipts = @store.receipts.purchase_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:purchase]
    receipts = @store.receipts.sale_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:sale]
    receipts = @store.receipts.adjustment_receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:adjustment]
    receipts ||= @store.receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}])
    receipts = receipts.created_after(params[:before]) if params[:before]
    receipts = receipts.created_before(params[:end]) if params[:end]
    total = (receipts.count / 25.0).ceil
    res = {
        receipts: receipts.page(params[:page]).as_json(include: [{:transactions => {include: [{seller_item: {include: :itemable}},
                                                                              buyer_item: {include: :itemable},
                                                                              adjust_item: {include: :itemable}]}},
                                                                 :med_batches]),
        total_count: total
    }
    render json: prepare_json(res), status: 200
  end

  def show
    receipt = @store.receipts.find(params[:id])
    render_receipt(receipt)
  end

  def create
    receipt = @store.receipts.create!(receipt_params)
    render_receipt(receipt)
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

  def render_receipt(receipt)
    render json: prepare_json(receipt.as_json(include: [{:transactions => {include: [{seller_item: {include: :itemable}},
                                                                                     buyer_item: {include: :itemable},
                                                                                     adjust_item: {include: :itemable}]}},
                                                        :med_batches]
    )), status: 200
  end

  def get_store
    @store = @current_user.store if @current_user
  end

end
