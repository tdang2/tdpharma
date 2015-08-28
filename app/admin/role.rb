ActiveAdmin.register Role do
  menu priority: 4
  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    role: [:id, :name]
    end
  end
  filter :name
  filter :users

  form do |f|
    f.inputs do
      f.input :name
    end
    actions
  end


end
