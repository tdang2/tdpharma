class TransactionSerializer < ActiveModel::Serializer
  attributes :id,
             :amount,
             :delivery_time,
             :due_date,
             :paid,
             :performed,
             :total_price,
             :transaction_type,
             :notes,
             :new_total,
             :status,
             :created_at


  belongs_to :receipt, serializer: ReceiptSimpleSerializer
  belongs_to :user, serializer: UserSimpleSerializer
  belongs_to :store, serializer: StoreSimpleSerializer
  belongs_to :inventory_item, serializer: InventoryItemSimpleSerializer
  belongs_to :med_batch, serializer: MedBatchSimpleSerializer


end
