class StoreSimpleSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :phone,
             :inventory_items_count
end