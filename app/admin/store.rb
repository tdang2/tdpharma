ActiveAdmin.register Store do
  menu priority: 5

  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    store: [:id, :name, :phone,
                            location_attributes:[:id, :name, :address],
                            image_attributes:[:id, :photo],
                            document_attributes: [:id, :doc]]
    end
  end
  filter :name
  filter :location
  filter :company

  form multipart: true do |f|
    f.inputs 'Store' do
      f.semantic_errors
      f.input :name
      f.input :phone
      f.input :photo, as: :file, for: [:image, f.object.image || Image.new]
      f.has_many :documents, for: [:documents, f.object.documents || Document.new] do |t|
        t.input :doc, as: :file
        t.input :_destroy, :as=>:boolean, :required => false, :label=>'Remove' unless t.object.new_record?
      end
      f.has_many :location, for: [:location, f.object.location || Location.new], new_record: false do |t|
        t.input :name
        t.input :address
      end
    end
    f.actions
  end

  index do
    selectable_column
    column :id
    column :name
    column :company
    column :phone
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :phone
      row :image
      row :location
      row :documents
      row :company
    end
  end


end
