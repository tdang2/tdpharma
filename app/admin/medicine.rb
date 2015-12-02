ActiveAdmin.register Medicine do
  menu priority: 8
  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    medicine: [:id, :name, :concentration, :concentration_unit, :med_form,
                               image_attributes: [:id, :photo]
                    ]
    end
  end

  filter :name
  filter :concentration
  filter :concentration_unit
  filter :med_form
  filter :mfg_location
  filter :manufacturer

  form multipart: true do |f|
    f.inputs 'Medicine' do
      f.semantic_errors *f.object.errors.keys
      f.input :name
      f.input :concentration
      f.input :concentration_unit
      f.input :med_form
      f.input :manufacturer
      f.input :mfg_location
      f.has_many :image, for: [:image, f.object.image || Image.new], new_record: false do |t|
        t.input :photo, as: :file
      end
    end
  end

  index do
    selectable_column
    column :id
    column :name
    column :concentration
    column :concentration_unit
    column :med_form
    column :manufacturer
    column :mfg_location
    column 'Item Count' do |f|
      f.inventory_items.count
    end
    column 'Batch Count' do |f|
      f.med_batches.count
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :concentration
      row :concentration_unit
      row :med_form
      row :mfg_location
      row :manufacturer
      row :image do
        image_tag(medicine.image.photo.url(:thumb)) if medicine.image and medicine.image.photo.url
      end
    end
    if medicine.inventory_items.count > 0
      panel 'Inventory Item' do
        table_for g=medicine.inventory_items do |d|
          if g.present?
            column('ID', :sortable => :id) {|id| link_to "#{id.id}", admin_inventory_item_path(id)}
            column 'Store' do
              d.store.name
            end
            column :created_at
          end
        end
      end
    end
    if medicine.med_batches.count > 0
      panel 'Med Batches' do
        table_for g=medicine.med_batches do |d|
          if g.present?
            column('ID', :sortable => :id) {|id| link_to "#{id.id}", admin_med_batch_path(id)}
            column 'Store' do
              d.store.name
            end
            column :mfg_date
            column :expire_date
            column :created_at
          end
        end
      end
    end

  end



end
