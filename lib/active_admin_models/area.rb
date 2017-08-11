ActiveAdmin.register Area do
  menu parent: "Settings", label: "Neighborhoods", url: -> { admin_areas_path }, priority: 3
  permit_params :name, :description, :is_active, :id, :city_id, :latitude, :longitude, :position,
                :images_attributes => [:id, :image, :description, :display_order, :_destroy],
                translations_attributes: [:locale, :id, :name, :description, :_destroy]

  config.sort_order = 'position_asc'

  sortable

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  scope :all, :default => true
  scope :active do |c|
    c.where(:is_active => true)
  end

  index do
    sortable_handle_column
    column :name
    #column :description
    column :images do |a| a.images.count end
    column :city do |c|  auto_link c.city end
    column :country do |c|  auto_link c.city.country end
    column :latitude
    column :longitude
    column :position
    column :is_active
    translation_status
    actions
  end

  filter :name
  filter :city_id, as: :select, collection: proc { City.active.pluck(:slug, :id) }

  form html: {multipart: true} do |f|
    f.inputs "Area Details" do
      f.translated_inputs "Translated fields", switch_locale: false do |t|
        t.input :name
        t.input :description
      end
      f.input :city
      f.input :latitude
      f.input :longitude
      f.input :position
      f.input :is_active
      f.has_many :images do |p|
        p.input :image, :hint => p.object.image.exists?? f.template.image_tag(p.object.image.url(:medium)): ''
        p.input :description
        p.input :display_order
        p.input :_destroy, as: :boolean
      end

    end
    f.actions
  end

  show do |c|
    attributes_table do
      translated_row(:name, inline: false)
      translated_row(:description, inline: false)
      row :latitude
      row :longitude
      row :is_active
      c.images.each do |i|
        row :image do
          div do
            image_tag(i.image.url(:medium))
          end
          div do
            i.description
          end
        end
      end
    end
  end

end
