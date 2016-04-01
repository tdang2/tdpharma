class Api::V1::TransactionsController < ApplicationController
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store
  rescue_from StandardError, with: :render_error

  def render_error(e)
    NewRelic::Agent.notice_error(e) if Rails.env.production?
    render json: prepare_json({errors: e.message}), status: 400
  end

  def index

  end

  def create
    raise 'Author is required' if has_empty_author_params?
    transaction = Transaction.create(transaction_params)
    if transaction.buyer_item
      render json: prepare_json(transaction.buyer_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    elsif transaction.seller_item
      render json: prepare_json(transaction.seller_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    elsif transaction.adjust_item
      render json: prepare_json(transaction.adjust_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
    end
  end

  def show
    t = Transaction.find(params[:id])
    if t.buyer_id == @store.id || t.seller_id == @store.id || t.adjust_store_id == @store.id
      render json: prepare_json(t.as_json(include: [:receipt, :seller_item, :buyer_item, :adjust_item,
                                                    :sale_user, :purchase_user, :adjust_user,
                                                    {med_batch: {include: [:medicine]}}])), status: 200
    else
      render json: prepare_json({message: 'Not authorized to view this transaction'}), status: 400
    end
  end

  def update
    t = Transaction.find(params[:id])
    raise 'Author is required' if has_empty_author_params?
    if t.buyer_id == @store.id || t.seller_id == @store.id || t.adjust_store_id == @store.id
      t.update!(transaction_update_params)
      render json: prepare_json(t.as_json(include: [:receipt, :seller_item, :buyer_item, :adjust_item, :sale_user,
                                                    :purchase_user, :adjust_user, {med_batch: {include: [:medicine]}}])), status: 200
    else
      raise 'Not authorized to edit this transaction'
    end
  end

  def destroy

  end

  private
  def transaction_update_params
    params.require(:transaction).permit(:amount, :new_total, :total_price, :delivery_time, :due_date, :paid, :performed, :med_batch_id, :status,
                                        :purchase_user_id, :sale_user_id, :adjust_user_id, :notes, :buyer_item_id, :seller_item_id, :adjust_item_id)
  end

  def has_empty_author_params?
    params[:transaction][:purchase_user_id].blank? and params[:transaction][:sale_user_id].blank? and params[:transaction][:adjust_user_id].blank?
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :new_total, :total_price, :delivery_time, :due_date, :paid, :performed, :transaction_type,
                                        :purchase_user_id, :buyer_item_id, :seller_item_id, :sale_user_id, :seller_id, :med_batch_id,
                                        :buyer_id, :adjust_store_id, :adjust_item_id, :adjust_user_id, :notes)
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end