ActiveAdmin.register Listing do
  menu parent: "Listings", url: -> { admin_listings_path(:scope => :all) }, label: "Spaces", priority: 1
  permit_params :featured, :address_1, :address_2, :zip, :city_name, :area_name, :country_name, :country_id, :country_code,
                :latitude, :longitude,
                :user_id,
                #description
                :title, :headline, :alias, :description,
                :location_type, {:space_usage_type => []},
                #space
                :square_measure, :house_rules, :retail_space, :storage_space,
                :floor, :lease_start,
                {:space_features => []}, {:inside_space => []}, {:outside_space => []},
                :always_available,
                #money
                :currency, :rent_per_day, :rent_per_week, :rent_per_month,
                :security_depot, :min_duration,
                #visitation
                :visitation, :visitation_contact_email,
                :visitation_dates, :visitation_contact_person, :visitation_contact_phone,
                :vat_taxable,
                :offline_bookable,
                :locale,
                :conversation_text,
                #legal
                :is_enabled,
                :is_deleted,
                :is_landlord, :allowed, :landlord_id,
                :landlord_attributes => [
                  :company,
                  :first_name,
                  :last_name,
                  :address_1,
                  :address_2,
                  :zip,
                  :city,
                  :country,
                  :phone
                ],
                :listing_images_attributes => [:id, :attachment, :kind, :description, :file_name, :_destroy],
                :listing_documents_attributes => [:id, :attachment, :kind, :description, :file_name, :_destroy]


  #actions :index, :show

  config.sort_order = 'updated_at_desc'

  batch_action :destroy, false
  batch_action :turn_premium_6months do |selection|
    if selection.empty?
      redirect_to(collection_path, notice: 'no listings selected')
    else
      selection.each do |listing_id|
        Listing.transaction do
          listing = Listing.find(listing_id)

          if listing.premium_listing.empty?
            service = ListingService.new(listing)

            listing.offline_bookable = true
            service.create_product_if_needed!
            product = listing.products.premium_listing.last

            # make status inactive so it's a one-time thing (no automatic renewal)
            product.status = Product::Status::INACTIVE
            product.valid_until = Date.today + 6.months
            product.save!

          else
            # what to do here?
          end
        end
      end
      redirect_to collection_path, notice: "Total of #{selection.count} listings updated."
    end
  end

  scope :all do |listings|
    listings.not_draft
  end

  scope :pending do |listings|
    listings.pending
  end

  scope :rejected do |listings|
    listings.rejected
  end

  scope :draft do |listings|
    listings.draft
  end

  controller do
    def scoped_collection
      Listing.all
    end

    def find_resource
      if params[:version]
        return Listing.find(params[:id]).versions.find(params[:version]).reify
      else
        return Listing.find(params[:id])
      end

    end

    def destroy
      listing = Listing.find(params[:id])
      listing.update!(is_deleted: true)
      redirect_to({:action => :index}, {:notice => "Listing deleted."})
    end
  end

  member_action :review, method: :put do
    listing = Listing.find(params[:id])
    listing_params = params.require(:listing).permit(:is_approved, :approval_feedback)
    listing.review!(listing_params[:is_approved], listing_params[:approval_feedback])
    redirect_to({:action => :show}, {:notice => "Listing reviewed!"})
  end

  attrs = {
    :description => [
        :title, :headline, :alias, :description, :locale,
        :location_type, :space_usage_type,
        :floor, :lease_start, :conversation_text
    ],

    :location =>  [
        :address_1, :address_2, :zip, :city_name, :area_name, :country,
        :latitude, :longitude
    ],


    :space => [
        :square_measure, :house_rules, :retail_space, :storage_space,
        :space_features, :inside_space, :outside_space,
        :always_available
    ],

    :money => [
        :currency, :rent_per_day, :rent_per_week, :rent_per_month,
        :security_depot, :min_duration
    ],

    :visitation => [
        :visitation, :visitation_contact_email,
        :visitation_dates, :visitation_contact_person, :visitation_contact_phone
    ]

  }

  index do
    column resource_selection_toggle_cell, class: 'selectable' do |resource|
      resource_selection_cell resource
    end

    column :id
    column :title
    column :is_enabled
    column :featured
    column :offline_bookable
    column :landlord do |l| text_node user_link(l.user) end
    column :availability do |l| link_to("Availability...", admin_listing_availabilities_path(l)) end
    column :country
    column :city_name
    column :images do |l| text_node l.listing_images.size end
    actions
  end

  show do
    attrs.keys.in_groups_of(2, false) do |groups|
      columns do
        groups.each do |s|
          column do
            panel s.to_s.titleize do
              attributes_table_for Admin::ListingDecorator.new(listing) do
                attrs[s].each do |attr|
                  row attr
                end
              end
            end
          end
        end
      end
    end


    columns do
      column do
        panel "Landlord" do
          div user_link(listing.user)
          if listing.is_landlord
            div text_node "User is Landlord."

          else listing.is_landlord
            attributes_table_for listing.landlord do
              [:company, :first_name, :last_name, :address_1, :address_2, :zip, :city, :country, :phone].each do |attr|
                row attr
              end
            end
          end
        end
      end
    end

    columns do
      column do
        panel "Images" do
          listing.listing_images.where('listing_attachments.created_at <= ?', listing.updated_at).each do |image|
            attributes_table_for image do
              row :description
              row :file_name do |i| i.attachment_file_name end
              row :images do |i|
                image_tag i.attachment.url(:thumb)
              end
            end
          end
        end
      end
      column do
        panel "Documents" do
          listing.listing_documents.where('listing_attachments.created_at <= ?', listing.updated_at).each do |doc|
            attributes_table_for doc do
              row :description
              row :file do |f|
                link_to(doc.attachment_file_name, doc.attachment.url)
              end
            end
          end
        end
      end
    end

    columns do
      column do
        panel "Availabilities" do
          span link_to("View...", admin_listing_availabilities_path(listing))
          table_for listing.availabilities do
            column :starts_at
            column :ends_at
            column :is_available
            column :rent_per_day
            column :rent_per_week
            column :rent_per_month
            column :actions do |a| link_to("Show", admin_listing_availability_path(a.listing, a)) end
          end
        end
      end
    end

    columns do
      column do
        panel "Bookings" do
          span link_to("View...", admin_bookings_path(listing_id_eq: listing.id))
          table_for listing.bookings do
            column :id
            column :from
            column :to
            column :user
            column :status
          end
        end
      end
    end

    columns do
      column do
        panel "History" do
          begin
            table_for(([Listing.find(listing.id)] + listing.versions.map(&:reify)).flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
              column :updated_at do |t| t.version.nil?? '--': l(t.version.created_at, format: :short) end
              column :title
              column :approved? do |t| t.is_approved? end
              column :approval_feedback
              column :show do |t|
                if t.version.nil? && listing.version.nil?
                  text_node "Live"
                elsif t.version && t.version.id == listing.version.try(:id)
                  text_node "Version #{t.version.id}"
                elsif t.version
                  link_to("Show version #{t.version.id}", admin_listing_path(t, version: t.version.id))
                else
                  link_to("Show latest", admin_listing_path(t))
                end
              end
            end
          rescue
            span "Cannot show history for this listing. Please contact support."
          end
        end
      end
    end

  end

  filter :title
  filter :updated_at
  filter :city
  filter :country
  filter :user_email, as: :string #, as: :select, collection: proc{ User.all.collect{|u| [u.display_name, u.id]} }
  filter :user_company, as: :string
  filter :is_enabled
  filter :is_deleted
  filter :is_approved
  filter :featured, as: :boolean



  sidebar "Review", only: :show, if: Proc.new{ resource.is_pending? } do
    render partial: 'review_form', locals: {listing: listing}
  end

  sidebar "Review", only: :show, if: Proc.new{ !resource.is_pending? } do
    attributes_table_for listing do
      row :is_approved do |l| l.is_approved.to_s end
      row :approval_feedback
    end
  end

  sidebar 'Products', only: :show do
    table_for listing.premium_listing.order(created_at: :desc).limit(30) do
      column :product do |p|
        link_to("#{p.kind}", admin_product_path(p))
      end
      column :valid_until do |p|
        p.valid_until
      end
      column :active do |p|
        p.within_validity?
      end
    end
  end

  sidebar 'Customer Support', only: :show do
    table_for resource.tickets.order(created_at: :desc).limit(30) do
      column :ticket do |ticket|
        ticket_link(ticket)
      end
    end
  end
  

  form html: {multipart: true} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs "Description" do
      f.input :user, collection: user_collection
      f.input :title
      f.input :headline
      f.input :description
      f.input :location_type, collection: admin_enum_collection(Settings::LOCATION_TYPE, "enum.location")
      f.input :space_usage_type, as: :check_boxes, collection: admin_enum_collection(Settings::SPACE_USAGE_TYPE, "enum.space_usage")
      f.input :floor
      f.input :lease_start
      f.input :conversation_text
    end

    f.inputs "Location" do
      f.input :address_1
      f.input :address_2
      f.input :zip
      f.input :city_name
      f.input :area_name
      f.input :country, collection: country_collection
      f.input :latitude
      f.input :longitude
    end

    f.inputs "Space" do
      f.input :house_rules
      f.input :square_measure, collection: Settings::MEASURE
      f.input :retail_space
      f.input :storage_space
      f.input :space_features, as: :check_boxes, collection: admin_enum_collection(Settings::SPACE_FEATURE, "enum.space_feature")
      f.input :inside_space, as: :check_boxes, collection: admin_enum_collection(Settings::INSIDE_SPACE, "enum.inside_space")
      f.input :outside_space, as: :check_boxes, collection: admin_enum_collection(Settings::OUTSIDE_SPACE, "enum.outside_space")
      f.input :always_available
    end

    f.inputs "Money" do
      f.input :currency, collection: Settings::CURRENCY_CODES, include_blank: false
      f.input :rent_per_day
      f.input :rent_per_week
      f.input :rent_per_month
      f.input :security_depot
      f.input :min_duration
      f.input :vat_taxable
    end

    f.inputs "Visitation" do
      f.input :visitation
      f.input :visitation_contact_email
      f.input :visitation_contact_person
      f.input :visitation_dates
      f.input :visitation_contact_phone
    end

    f.inputs "Landlord" do
      f.input :is_landlord, label: 'user is landlord?'
      f.input :landlord, collection: landlord_collection
    end

    f.inputs "Images" do
      f.has_many :listing_images, allow_destroy: true do |p|
        p.input :attachment, :hint => p.object && p.object.attachment.exists?? f.template.image_tag(p.object.attachment.url(:normal)): ''
        p.input :description
        #p.input :kind, as: :hidden, input_html: {value: 'listing_image'}
      end
    end

    f.inputs "Documents" do
      f.has_many :listing_documents, allow_destroy: true do |p|
        p.input :attachment, :hint => p.object && p.object.attachment.exists?? f.template.link_to(p.object.attachment_file_name, p.object.attachment.url): ''
        p.input :description
        #p.input :kind, as: :hidden, input_html: {value: 'listing_document'}
      end
    end

    f.input :is_enabled
    f.input :is_deleted
    f.input :offline_bookable
    f.input :allowed, label: "Legally allowed..."
    f.input :featured

    f.actions
  end

end
