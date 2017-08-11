ActiveAdmin.register Search do
  menu parent: "Bookmarks", label: "Searches", url: -> { admin_searches_path }, priority: 1

  config.sort_order = 'updated_at_desc'

  #permit_params :user_id, :place, :formatted_address, :description, :url, :admin_comment, :state, :city_name, :tags, :attachments, :starts_at, :ends_at

  filter :user do |l| text_node user_link(l.user) end
  filter :price_currency
  filter :price_min_cents
  filter :price_max_cents
  filter :space_min
  filter :space_max
  filter :square_measure
  filter :date_min
  filter :date_max


  index do
    id_column
    column :user do |l| text_node user_link(l.user) end
    column :formatted_address
    #column("Currency",:price_currency)
    column("Min. Price", :price_min_cents) {|s| "#{s.price_currency} #{s.price_min_cents}"} #humanized_money doesnt work correctly, numbers include 2 cents digits!!
    column("Max. Price", :price_max_cents) {|s| "#{s.price_currency} #{s.price_max_cents}"}
    #column("Sq./Ft.", :square_measure)
    column("Min. Space", :space_min) {|s| "#{s.square_measure} #{s.space_min}"}
    column("Max. Space", :space_max) {|s| "#{s.square_measure} #{s.space_max}"}
    column("Min. Date", :date_min)
    column("Max. Date", :date_max)
    actions
  end

  form html: {multipart: true} do |f|
    f.inputs do
      f.input :user_id, collection: user_collection
      f.input :place
      f.input :formatted_address
      f.input :latitude
      f.input :longitude
    end

    f.inputs "Price" do
      f.input :price_currency, collection: Settings::CURRENCY_CODES, include_blank: false
      f.input :price_min_cents
      f.input :price_max_cents
      f.input :price_type
    end

    f.inputs "Space" do
      f.input :square_measure, collection: Settings::MEASURE
      f.input :space_min
      f.input :space_max
      f.input :location_type, collection: admin_enum_collection(Settings::LOCATION_TYPE, "enum.location")
      f.input :space_usage_type, as: :check_boxes, collection: admin_enum_collection(Settings::SPACE_USAGE_TYPE, "enum.space_usage")
    end

    f.inputs "Date" do
      f.input :date_min
      f.input :date_max
    end


    f.actions
  end

end
