class Api::V1::ReceiptsController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  def index
    receipts = @store.receipts.purchase_receipts.includes(transactions: [:user, {inventory_item: :itemable}]) if params[:purchase]
    receipts = @store.receipts.sale_receipts.includes(transactions: [:user, {inventory_item: :itemable}]) if params[:sale]
    receipts = @store.receipts.adjustment_receipts.includes(transactions: [:user, {inventory_item: :itemable}]) if params[:adjustment]
    receipts ||= @store.receipts.includes(transactions: [{inventory_item: :itemable}])
    receipts = receipts.created_max(params[:max_date]) if params[:max_date]
    receipts = receipts.created_min(params[:min_date]) if params[:min_date]
    res = {
        receipts: receipts.reverse_order.page(params[:page]).as_json(include: [{:transactions => {include: [:med_batch,
                                                                                                            :user,
                                                                                                            {inventory_item: {include: :itemable}}
                                                                                                            ]
                                                                                                  }
                                                                               },
                                                                               :med_batches]),
        total_count: receipts.count
    }
    render json: res, status: 200
  end

  def show
    receipt = @store.receipts.find(params[:id])
    render_receipt(receipt)
  end

  def create
    params[:receipt][:purchase_transactions_attributes].each {|p| p[:store_id] ||= @store.id } if params[:receipt][:purchase_transactions_atttributes]
    params[:receipt][:adjustment_transactions_attributes].each {|p| p[:store_id] ||= @store.id } if params[:receipt][:adjustment_transactions_attributes]
    params[:receipt][:med_batches_attributes].each {|p| p[:store_id] ||= @store.id} if params[:receipt][:med_batches_attributes]
    if params[:receipt][:sale_transactions_attributes]
      params[:receipt][:sale_transactions_attributes].each do |p|
        p[:store_id] ||= @store.id
        p[:inventory_item_id] ||= @store.med_batches.find(p[:med_batch_id]).inventory_item_id if params[:receipt][:receipt_type] == 'sale'
      end
    end
    receipt = @store.receipts.create!(receipt_params)
    render_receipt(receipt.reload)
  end

  def update
    if params[:receipt][:sale_transactions_attributes]
      raise 'Author is required' if params[:receipt][:sale_transactions_attributes].any?{|t| t[:user_id].blank?}
    end
    if params[:receipt][:purchase_transactions_attributes]
      raise 'Author is required' if params[:receipt][:purchase_transactions_attributes].any?{|t| t[:user_id].blank?}
    end
    if params[:receipt][:adjustment_transactions_attributes]
      raise 'Author is required' if params[:receipt][:adjustment_transactions_attributes].any?{|t| t[:user_id].blank?}
    end
    receipt = @store.receipts.find(params[:id])
    receipt.update!(receipt_params)
    render_receipt(receipt.reload) # reload data to get latest info updated by callback functions
  end

  private
  def receipt_params
    params.require(:receipt).permit(:receipt_type, :total, :store_id,
                                    med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :store_id,
                                                             :amount_per_pkg, :number_pkg, :total_units, :total_price,
                                                             :user_id, :category_id, :paid, :medicine_id, :inventory_item_id],
                                    purchase_transactions_attributes: [:id, :amount, :new_total, :delivery_time, :due_date, :performed,
                                                                        :status, :transaction_type, :total_price, :notes, :paid,
                                                                        :user_id, :inventory_item_id, :med_batch_id, :store_id
                                                                        ],
                                    sale_transactions_attributes: [:id, :amount, :new_total, :delivery_time, :due_date, :performed,
                                                                   :status, :transaction_type, :total_price, :notes, :paid,
                                                                   :user_id, :inventory_item_id, :med_batch_id, :store_id
                                                                   ],
                                    adjustment_transactions_attributes: [:id, :amount, :new_total, :delivery_time, :due_date, :performed,
                                                                         :status, :transaction_type, :total_price, :notes, :paid,
                                                                         :user_id, :inventory_item_id, :med_batch_id, :store_id
                                                                        ]
    )
  end

  def render_receipt(receipt)
    render json: receipt.as_json(include: [{:transactions => {include: [:med_batch,
                                                                                     :user,
                                                                                     {inventory_item: {include: :itemable}}
                                                                                    ]}
                                                        },
                                                        :med_batches
                                                        ]
    ), status: 200
  end

  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end

end
