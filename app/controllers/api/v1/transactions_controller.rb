class Api::V1::TransactionsController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  has_scope :purchase, type: :boolean
  has_scope :sale, type: :boolean
  has_scope :adjustment, type: :boolean
  has_scope :active, type: :boolean
  has_scope :deprecated, type: :boolean
  has_scope :by_user
  has_scope :by_med_batch
  has_scope :by_inventory_item
  has_scope :created_max
  has_scope :created_min

  def index
    transactions = apply_scopes(@store.transactions)
    render json: transactions, status: 200
  end

  def create
    raise 'Author is required' if has_empty_author_params?
    transaction = Transaction.create(transaction_params)
    if transaction.inventory_item
      render json: transaction, status: 200
    end
  end

  def show
    t = Transaction.find(params[:id])
    if t.store_id == @store.id
      render json: t, status: 200
    else
      render json: {message: 'Not authorized to view this transaction'}, status: 400
    end
  end

  def update
    raise 'Author is required' if has_empty_author_params?
    t = Transaction.find(params[:id])
    case t.transaction_type
      when 'purchase'
        t = t.becomes(PurchaseTransaction)
      when 'sale'
        t = t.becomes(SaleTransaction)
      when 'adjustment'
        t = t.becomes(AdjustmentTransaction)
      else
        raise 'Invalid data'
    end
    if t and t.store_id == @store.id
      t.update!(transaction_update_params)
      render json: t, status: 200
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
    @store = current_resource_owner.store if current_resource_owner
  end


end