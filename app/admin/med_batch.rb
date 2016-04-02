ActiveAdmin.register MedBatch do
  menu priority: 10
  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    med_batch: [:id, :mfg_date, :expire_date, :package, :mfg_location, :store_id,
                                     :amount_per_pkg, :number_pkg, :total_units, :total_price, :user_id, :category_id]
    end
  end

  filter :inventory_item
  filter :expire_date
  filter :mfg_date
  filter :package
  filter :store




end
