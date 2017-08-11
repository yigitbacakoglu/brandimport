ActiveAdmin.register City do
  menu parent: "Settings", url: -> { admin_cities_path }, priority: 2
  permit_params :name, :description, :country_id, :language, :latitude, :longitude,
                :is_active, :id, :position, :is_major,
                :images_attributes => [:id, :image, :description, :display_order, :_destroy],
                :attachments_attributes => [:id, :attachment, :description, :position, :locale, :_destroy],
                translations_attributes: [:locale, :id, :name, :description, :links, :legal, :_destroy]


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
    column :slug
    #column :description
    column :images do |c| c.images.count end
    column :areas do |c| c.areas.count end
    column :latitude
    column :longitude
    column :language
    column :country
    column :is_major
    column :position
    column :is_active
    #column :geoname_id
    #column :timezone
    translation_status
    column :areas do |c|
      link_to "View", admin_areas_path('q[city_id_eq]' => c.id)
    end
    actions
  end

  filter :name
  filter :description
  filter :country, as: :select, collection: proc{ Country.active.pluck(:slug, :id) }

  form html: {multipart: true} do |f|
    #f.semantic_errors *f.object.errors.keys
    f.inputs "City Details" do
      f.translated_inputs "Translated fields", switch_locale: false do |t|
        t.input :name
        t.input :description
        t.input :links
        t.input :legal
      end
      f.input :country
      f.input :language, as: :select, collection: Settings::AVAILABLE_LOCALE
      f.input :latitude
      f.input :longitude
      f.input :is_major
      f.input :position
      f.input :is_active
      f.has_many :images do |p|
        p.input :image, :hint => p.object.image.exists?? f.template.image_tag(p.object.image.url(:medium)): ''
        p.input :description
        p.input :display_order
        p.input :_destroy, as: :boolean
      end
      f.has_many :attachments, heading: 'Documents' do |a|
          a.input :locale, collection: Settings::AVAILABLE_LOCALE
          a.input :attachment , :hint => (f.template.content_tag(:a, href: a.object.attachment.url) do a.object.description end)
          a.input :description
          a.input :position
          a.input :_destroy, as: :boolean
      end
    end
    f.actions
  end

  show do |c|
    attributes_table do
      translated_row(:name, inline: false)
      translated_row(:description, inline: false)
      translated_row(:links, inline: false) do |c|
        markdown(c.links)
      end
      translated_row(:legal, inline: false) do |c|
        markdown(c.legal)
      end
      row :country
      row :language
      row :latitude
      row :longitude
      row :is_major
      row :position
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
      c.attachments.each do |a|
        row :attachment do
          div do
            content_tag(:a, href: a.attachment.url) do
              "#{a.locale}: #{a.description}"
            end
          end
        end
      end
    end
  end

end
