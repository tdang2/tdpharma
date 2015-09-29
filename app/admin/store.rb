ActiveAdmin.register Store do
  menu priority: 7

  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    store: [:id, :name, :phone, :company_id, employee_ids: [],
                            location_attributes:[:id, :name, :address],
                            image_attributes:[:id, :photo],
                            documents_attributes: [:id, :doc]]
    end

  end
  filter :name
  filter :location
  filter :company

  form multipart: true do |f|
    f.inputs 'Store' do
      f.semantic_errors *f.object.errors.keys
      f.input :name
      f.input :phone
      f.input :employees, as: :select, collection: User.all.map{|u| ["#{u.first_name} #{u.last_name}", u.id]}
      f.has_many :image, for: [:image, f.object.image || Image.new], new_record: false do |t|
        t.input :photo, as: :file
      end
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
      row :image do
        image_tag(store.image.photo.url(:thumb)) if store.image and store.image.photo.url
      end
      row :location do
        store.location.address
      end
      row :company
    end
    if store.documents.count > 0
      panel 'Document' do
        table_for g=store.documents do |d|
          if g.present?
            column('ID', :sortable => :id) {|d| link_to "#{d.id}", d.doc.url, :target => "_blank"}
            column :created_at
          end
        end
      end
    end
    if store.employees.count > 0
      panel 'Employee' do
        table_for g=store.employees do |e|
          if g.present?
            column('ID', :sortable => :id) {|id| link_to "#{id.id}", admin_user_path(id)}
            column 'First Name', :first_name
            column 'Last Name', :last_name
            column 'Email', :email
            column 'Sign In Count', :sign_in_count
          end
        end
      end
    end
  end


end
