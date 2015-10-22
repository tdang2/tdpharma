class Api::V1::TransactionsController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index

  end

  def create
    begin
      transaction = Transaction.create(transaction_params)
      if transaction.buyer_item
        render json: prepare_json(transaction.buyer_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
      elsif transaction.seller_item
        render json: prepare_json(transaction.seller_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
      elsif transaction.adjust_item
        render json: prepare_json(transaction.adjust_item.as_json(include: [:itemable, :sale_price], methods: :photo_thumb)), status: 200
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def show

  end

  def update

  end

  def destroy

  end

  private
  def transaction_params
    params.require(:transaction).permit(:amount, :total_price, :delivery_time, :due_date, :paid, :performed, :transaction_type,
                                        :purchase_user_id, :buyer_item_id, :seller_item_id, :sale_user_id, :seller_id,
                                        :buyer_id, :adjust_store_id, :adjust_item_id, :adjust_user_id)
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end