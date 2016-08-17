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
    if transaction.inventory_item
      render json: prepare_json(transaction.inventory_item.as_json(include: [:itemable,
                                                                             :sale_price
                                                                            ],
                                                                   methods: [:photo_thumb]
                                                                  )), status: 200
    end
  end

  def show
    t = Transaction.find(params[:id])
    if t.store_id == @store.id
      render json: prepare_json(t.as_json(include: [:receipt,
                                                    :inventory_item,
                                                    :user,
                                                    {med_batch: {include: [:medicine]}}
                                                    ]
                                          )), status: 200
    else
      render json: prepare_json({message: 'Not authorized to view this transaction'}), status: 400
    end
  end

  def update
    raise 'Author is required' if has_empty_author_params?
    t = Transaction.find(params[:id])
    t = t.becomes(t.transaction_type.constantize)
    if t and t.store_id == @store.id
      t.update!(transaction_update_params)
      render json: prepare_json(t.as_json(include: [:receipt,
                                                    :inventory_item,
                                                    :user,
                                                    {med_batch: {include: [:medicine]}}
                                                    ]
                                          )), status: 200
    else
      raise 'Not authorized to edit this transaction'
    end
  end

  def destroy

  end

  private
  def transaction_update_params
    params.require(:transaction).permit(:amount, :new_total, :total_price, :delivery_time, :due_date, :paid, :performed, :med_batch_id, :status,
                                        :user_id, :notes, :inventory_item_id, :store_id)
  end

  def has_empty_author_params?
    params[:transaction][:user_id].blank?
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :new_total, :total_price, :delivery_time, :due_date, :paid, :performed, :transaction_type,
                                        :user_id, :inventory_item_id, :med_batch_id, :store_id, :notes)
  end

  def get_store
    @store = @current_user.store if @current_user
  end


end