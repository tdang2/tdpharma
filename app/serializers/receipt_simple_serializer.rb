class ReceiptSimpleSerializer < ActiveModel::Serializer
  attributes :id,
             :total,
             :receipt_type,
             :barcode
end
