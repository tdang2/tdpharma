ActiveAdmin.register Category do
  menu priority: 5
  controller do
    def permitted_params
      params.permit :utf8, :_method, :_method, :authenticity_token, :commit, :id,
                    category: [:id, :name, :parent_id, image_attributes:[:id, :photo]]
    end
  end

  filter :name
  filter :stores
  filter :children_count

  form multipart: true do |f|
    f.inputs 'Category' do
      f.semantic_errors *f.object.errors.keys
      f.input :name
      f.input :parent, as: :select
      f.has_many :image, for: [:image, f.object.image || Image.new], new_record: false do |t|
        t.input :photo, as: :file
      end
    end
    f.actions
  end

  index do
    selectable_column
    column :id
    column :name
    column :parent
    column :children_count
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :parent
      row :lft
      row :rgt
      row :children_count
      row :image do
        image_tag(category.image.photo.url(:thumb)) if category.image and category.image.photo.url
      end
    end
    if category.children.count > 0
      panel 'Sub Categories' do
        table_for g=category.children do |d|
          if g.present?
            column('ID', :sortable => :id) {|d| link_to "#{d.id}", admin_category_path(d)}
            column :name
            column :lft
            column :rgt
            column :children_count
          end
        end
      end
    end
  end


end
