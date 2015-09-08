ActiveAdmin.register Company do
  menu priority: 5

  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    company: [:id, :name, :phone, :description, :email, :website,
                              documents_attributes: [:id, :doc], image_attributes:[:id, :photo],
                              registered_location_attributes:[:id, :name, :address]]
    end
  end

  filter :name
  filter :email
  filter :website
  filter :store

  form multipart: true do |f|
    f.inputs 'Company' do
      f.semantic_errors *f.object.errors.keys
      f.input :name
      f.input :phone
      f.input :description, as: :text
      f.input :email
      f.input :website
      f.has_many :image, for: [:image, f.object.image || Image.new], new_record: false do |t|
        t.input :photo, as: :file
      end
      f.has_many :documents, for: [:documents, f.object.documents || Document.new] do |t|
        t.input :doc, as: :file
        t.input :_destroy, :as=>:boolean, :required => false, :label=>'Remove' unless t.object.new_record?
      end
      f.has_many :registered_location, for: [:registered_location, f.object.registered_location || Location.new], new_record: false do |t|
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
    column :phone
    column :email
    column :website
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :phone
      row :image do
        image_tag(company.image.photo.url(:thumb)) if company.image and company.image.photo.url
      end
      row :email
      row :website
      row :registered_location do |c|
        c.registered_location.address
      end
    end
    if company.documents.count > 0
      panel 'Document' do
        table_for g=company.documents do |d|
          if g.present?
            column('ID', :sortable => :id) {|d| link_to "#{d.id}", d.doc.url, :target => "_blank"}
            column :created_at
          end
        end
      end
    end
    if company.stores.count > 0
      panel "Stores" do
        table_for g=company.stores do |s|
          if g.present?
            column("ID", :sortable => :id) {|id| link_to "#{id.id}", admin_store_path(id)}
            column 'Name', :name
            column 'Phone', :phone
            column 'Location', :location
          end
        end
      end
    end
    if company.employees.count > 0
      panel 'Employee' do
        table_for g=company.employees do |e|
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
