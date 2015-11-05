ActiveAdmin.register InventoryItem do
  menu priority: 9
  actions :index, :show

  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    inventory_item: [:id, :amount, :status,
                                     image_attributes: [:id, :photo],
                                     sale_price_attributes: [:id, :amount, :discount]
                    ]
    end
  end

  filter :medicine
  filter :status
  filter :company
  filter :category

  index do
    selectable_column
    column :id
    column 'Name' do |f|
      f.itemable.name
    end
    column 'Concentration' do |f|
      f.itemable.concentration
    end
    column 'Concentration Unit' do |f|
      f.itemable.concentration_unit
    end
    column 'Form' do |f|
      f.itemable.med_form
    end
    column 'Store' do |f|
      f.store.name
    end
    column :amount
    column :status
    actions
  end

  show do
    attributes_table do
      row :id
      row :status
      row :amount
      row :concentration_unit
      row :med_form
      row :image do
        image_tag(inventory_item.image.photo.url(:thumb)) if inventory_item.image and inventory_item.image.photo.url
      end
    end
    if inventory_item.itemable
      panel 'Medicine' do
        table_for g=inventory_item.itemable do |d|
          if g.present?
            column 'ID', sortable: :id do |id|
              if id.class.name == 'Medicine'
                path = admin_medicine_path(id)
              end
              link_to "#{id.id}", path
            end
            column :name
            column :concentration
            column :concentration_unit
            column :med_form
          end
        end
      end
    end
    if inventory_item.itemable.med_batches.count > 0
      panel 'Med Batches' do
        table_for g=inventory_item.itemable.med_batches do
          if g.present?
            column('ID', :sortable => :id) {|id| link_to "#{id.id}", admin_med_batch_path(id)}
            column 'Store' do |f|
              f.store.name
            end
            column :created_at
          end
        end
      end
    end

  end


end
