class InventoryItemSimpleSerializer < ActiveModel::Serializer
  attributes :id,
             :amount,
             :status,
             :item_name
end