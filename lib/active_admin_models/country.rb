ActiveAdmin.register Country do
  menu parent: "Settings", url: -> { admin_countries_path }, priority: 1
  permit_params :name, :language, :currency, :square_measure, :is_active, :id, :iso3166_alpha2, :is_sepa, :vat,
                translations_attributes: [:locale, :id, :legal, :_destroy]

  config.sort_order = "is_active_desc, iso3166_alpha2_asc"

  controller do
    def find_resource
      scoped_collection.where(slug: params[:id]).first!
    end
  end

  scope :all, :default => true
  scope :active do |c|
    c.where(:is_active => true)
  end

  index do
    column :iso3166_alpha2
    column :name
    column :language
    column :currency
    column :square_measure
    column :vat
    column :updated_at
    column :cities do |c|
      link_to "View", admin_cities_path('q[country_id_eq]' => c.id)
    end
    translation_status
    actions
  end

  filter :is_active
  filter :name
  filter :currency
  filter :language
  filter :is_sepa


  form do |f|
    f.inputs "Admin Details" do
      f.input :name
      if f.object.new_record?
        f.input :iso3166_alpha2
      end
      f.input :language, collection: Settings::AVAILABLE_LOCALE
      f.input :currency, collection: Settings::CURRENCY
      f.input :square_measure, collection: Settings::MEASURE
      f.input :vat
      f.input :is_sepa
      f.translated_inputs "Translated fields", switch_locale: false do |t|
        t.input :legal
      end
      f.input :is_active
    end
    f.actions
  end

  show do |c|
    attributes_table do
      row :name
      row :iso31666_alpha2
      row :language
      row :currency
      row :square_measure
      row :vat
      row :is_sepa
      translated_row(:legal, inline: false) do |c|
        markdown(c.legal)
      end
      row :is_active
    end
  end

end
