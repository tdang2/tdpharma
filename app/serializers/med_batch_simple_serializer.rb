class MedBatchSimpleSerializer < ActiveModel::Serializer
  attributes :id,
             :mfg_date,
             :expire_date,
             :package,
             :amount_per_pkg,
             :total_units,
             :total_price,
             :paid,
             :barcode,
             :status,
             :number_pkg

  belongs_to :medicine
end