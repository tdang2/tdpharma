class MedicineSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :concentration,
             :concentration_unit,
             :med_form,
             :mfg_location,
             :manufacturer
end