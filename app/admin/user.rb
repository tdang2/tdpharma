ActiveAdmin.register User do
  menu priority: 3
  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
          user: [:id, :email, :first_name, :password, :phone, :last_name, role_ids: []]
    end

    def update
      if params[:user][:password].blank?
        params[:user].delete('password')
      end
      super
    end
  end

  filter :first_name
  filter :last_name
  filter :manager
  filter :email

  form multipart: true do |f|
    f.inputs 'User' do
      f.input :email
      f.input :password
      f.input :first_name
      f.input :last_name
      f.input :phone
      f.input :roles
      f.input :employees, :collection => f.object.new_record? ? User.pluck(:email) : User.where.not(id: f.object.id).pluck(:email)
    end
    f.actions
  end

  index do
    selectable_column
    column :id
    column :email
    column :first_name
    column :last_name
    column :phone
    column :sign_in_count
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :phone
      row :sign_in_count
      row :created_at
      row :updated_at
      row :manager
      row :employee
    end
    if user.roles.count > 0
      panel 'Role' do
        table_for g=user.roles do |d|
          if g.present?
            column('ID', :sortable => :id) {|d| link_to "#{d.id}", admin_role_path(d)}
            column :name
          end
        end
      end
    end
  end


end
