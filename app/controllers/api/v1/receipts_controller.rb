class Api::V1::ReceiptsController < ApplicationController
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store
  rescue_from StandardError, with: :render_error

  def render_error(e)
    NewRelic::Agent.notice_error(e) if Rails.env.production?
    render json: prepare_json({errors: e.message}), status: 400
  end

  def index
    receipts = @store.receipts.purchase_receipts.includes(transactions: [:sale_user, :purchase_user, :adjust_user, {seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:purchase]
    receipts = @store.receipts.sale_receipts.includes(transactions: [:sale_user, :purchase_user, :adjust_user, {seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:sale]
    receipts = @store.receipts.adjustment_receipts.includes(transactions: [:sale_user, :purchase_user, :adjust_user, {seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}]) if params[:adjustment]
    receipts ||= @store.receipts.includes(transactions: [{seller_item: :itemable}, {buyer_item: :itemable}, {adjust_item: :itemable}])
    receipts = receipts.created_max(params[:max_date]) if params[:max_date]
    receipts = receipts.created_min(params[:min_date]) if params[:min_date]
    res = {
        receipts: receipts.reverse_order.page(params[:page]).as_json(include: [{:transactions => {include: [:med_batch, :sale_user, :purchase_user, :adjust_user, {seller_item: {include: :itemable}},
                                                                              buyer_item: {include: :itemable},
                                                                              adjust_item: {include: :itemable}]}},
                                                                 :med_batches]),
        total_count: receipts.count
    }
    render json: prepare_json(res), status: 200
  end

  def show
    receipt = @store.receipts.find(params[:id])
    render_receipt(receipt)
  end

  def create
    if params[:receipt][:transactions_attributes]
      params[:receipt][:transactions_attributes].each do |p|
        p[:adjust_store_id] ||= @store.id if params[:receipt][:receipt_type] == 'adjustment'
        p[:seller_id] ||= @store.id if params[:receipt][:receipt_type] == 'sale'
        p[:seller_item_id] ||= @store.med_batches.find(p[:med_batch_id]).inventory_item_id if params[:receipt][:receipt_type] == 'sale'
      end
    end
    params[:receipt][:med_batches_attributes].each {|p| p[:store_id] ||= @store.id} if params[:receipt][:med_batches_attributes]
    receipt = @store.receipts.create!(receipt_params)
    render_receipt(receipt)
  end

  def update
    raise 'Author is required' if params[:receipt][:transactions_attributes].any?{|t| t[:purchase_user_id].blank? and t[:sale_user_id].blank? and t[:adjust_user_id].blank?}
    receipt = @store.receipts.find(params[:id])
    receipt.update!(receipt_params)
    render_receipt(receipt)
  end

  private
  def receipt_params
    params.require(:receipt).permit(:receipt_type, :total, :store_id,
                                    med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :store_id,
                                                             :amount_per_pkg, :amount_unit, :total_units, :total_price,
                                                             :user_id, :category_id, :paid, :medicine_id, :inventory_item_id],
                                    transactions_attributes: [:id, :amount, :new_total, :delivery_time, :due_date, :paid, :performed, :seller_id, :buyer_id,
                                                              :sale_user_id, :seller_item_id, :purchase_user_id, :buyer_item_id, :med_batch_id,
                                                              :adjust_item_id, :adjust_user_id, :adjust_store_id, :transaction_type, :total_price, :notes])
  end

  def render_receipt(receipt)
    render json: prepare_json(receipt.as_json(include: [{:transactions => {include: [:med_batch, :sale_user, :purchase_user, :adjust_user, {seller_item: {include: :itemable}},
                                                                                     buyer_item: {include: :itemable},
                                                                                     adjust_item: {include: :itemable}]}},
                                                        :med_batches]
    )), status: 200
  end

  def get_store
    @store = @current_user.store if @current_user
  end

end
