class Api::V1::ReceiptsController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  has_scope :purchase, type: :boolean
  has_scope :sale, type: :boolean
  has_scope :adjustment, type: :boolean
  has_scope :created_max
  has_scope :created_min

  def index
    receipts = apply_scopes(@store.receipts.includes(transactions: [:user, {inventory_item: :itemable}]))
    res = {
        receipts: convert_json(receipts.reverse_order.page(params[:page])),
        total_count: receipts.count
    }
    render json: res, status: 200
  end

  def show
    receipt = @store.receipts.find(params[:id])
    render json: convert_json(receipt), status: 200
  end

  def create
    params[:receipt][:purchase_transactions_attributes].each {|p| p[:store_id] ||= @store.id } if params[:receipt][:purchase_transactions_attributes]
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
  def convert_json(receipts)
    receipts.as_json(include: [{:transactions => {include: [:med_batch,
                                                            :user,
                                                            {inventory_item: {include: :itemable}}
                                                            ]
                                                  }
                                },
                               :med_batches])
  end


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
                                                                        {inventory_item: {include: :itemable}}]
                                                              }
                                           },
                                           :med_batches]), status: 200
  end

  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end

end
