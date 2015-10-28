class Api::V1::ReceiptsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      receipts = @store.receipts.purchase_receipts if params[:purchase]
      receipts = @store.receipts.sale_receipts if params[:sale]
      receipts = @store.receipts.adjustment_receipts if params[:adjustment]
      receipts ||= @store.receipts
      receipts = receipts.created_after(params[:before])
      receipts = receipts.created_before(params[:end])
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
      prepare_association_params
      receipt = @store.receipts.create(receipt_params)
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
                                     transactions_attributes: [:amount, :delivery_time, :due_date, :paid, :performed, :seller_id, :buyer_id,
                                                               :sale_user_id, :seller_item_id, :purchase_user_id, :buyer_item_id,
                                                               :adjust_item_id, :adjust_user_id, :adjust_store_id, :transaction_type, :total_price])
  end

  def prepare_association_params
    params[:receipt][:store_id] ||= @store.id
    if params[:receipt][:transactions_attributes]
      if params[:receipt][:receipt_type] == 'sale'
        params[:receipt][:transactions_attributes].each do |p|
          p[:seller_id] = @store.id
          p[:transaction_type] = 'activity'
        end
      elsif params[:receipt][:receipt_type] == 'purchase'
        params[:receipt][:transactions_attributes].each do |p|
          p[:buyer_id] = @store.id
          p[:transaction_type] = 'activity'
        end
      elsif params[:receipt][:receipt_type] == 'adjustment'
        params[:receipt][:transactions_attributes].each do |p|
          p[:adjust_store_id] = @store.id
          p[:transaction_type] = 'adjustment'
        end
      end
    end
  end

  def get_store
    @store = @current_user.store if @current_user
  end

end
