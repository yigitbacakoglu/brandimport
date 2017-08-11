ActiveAdmin.register User do
  menu parent: "Users", url: -> { admin_users_path }, label: "Users", priority: 1
  config.sort_order = 'updated_at_desc'
  permit_params :company, :company_no, :vat_no, :cancellation_policy, :id_verified, :phone_verified, :first_name, :last_name, :description, :address_1, :address_2, :zip, :city, :country_id, :phone, :email, :payout_method, :payout_country_id, :payout_payee_name, :payout_iban, :payout_bic, :payout_reference, :payout_paypal_email, :payout_currency, :notify_offers, :notify_news, :notify_upcoming, :notify_improve, :password, :password_confirmation, :is_active, :is_admin, :languages => [], :industry => []

remove_filter :voter_type

  config.batch_actions = false

  scope :admin do |users|
    users.admin
  end

  scope :all do |users|
    users
  end

  before_save do |u|
    u.languages = params[:user][:languages].reject(&:blank?)
    u.password = nil if params[:user][:password].blank?
    u.password_confirmation = nil if params[:user][:password].blank?
  end

  show do
    attributes_table do
      resource.class.columns.collect{|column| column.name.to_sym }.each do |c|
        row c
      end

      if resource.id_photo.exists?
        row :id_photo do
          link_to(resource.id_photo.original_filename, resource.id_photo.url)
        end
      end

    end
  end


  index do
    column :id
    column :display_name do |u| u.display_name end
    column :email
    column :country
    column :locale
    column :listings do |u|
      link_to("View (#{u.listings.not_draft.count})", admin_listings_path('q[user_id_eq]' => u.id))

    end
    column :bookings_sent do |u|
      link_to "View (#{u.bookings.count})", admin_bookings_path('q[user_id_eq]' => u.id)
    end

    column :sent_messages do |u|
      link_to "View", admin_messages_path('q[sender_id_eq]' => u.id)
    end

    column :payout do |u|
      ul do
      PayoutService.total_amount_for(u).each do |p|
        li "#{p.currency} #{humanized_money(p.amount)}"
      end
      end
    end
    actions
  end

  filter :email
  filter :country
  filter :first_name
  filter :last_name
  filter :company

  form do |f|
    f.inputs "Account Details", class: "inputs column-30" do
      f.input :company
      f.input :first_name
      f.input :last_name
      f.input :description
      f.input :address_1
      f.input :address_2
      f.input :zip
      f.input :city
      f.input :country
      f.input :phone
      f.input :email
      f.input :languages, as: :select, multiple: true, collection: languages_collection
      f.input :industry, as: :check_boxes, collection: admin_enum_collection(Settings::SPACE_USAGE_TYPE, "enum.space_usage")
      f.input :company_no
      f.input :vat_no
      f.input :cancellation_policy, as: :select, collection: CancellationPolicy.names.collect{ |policy_name| p = CancellationPolicy.from_name(policy_name); ["#{p.name.to_s.titleize} -- #{p.label}", policy_name] }
      f.input :id_verified
      f.input :phone_verified
      f.input :is_active
      f.input :is_admin
    end

    f.inputs "Payout Details", class: "inputs column-30" do
      f.input :payout_method, as: :select, collection: Settings::PAYOUT_METHOD
      f.input :payout_country
      f.input :payout_payee_name
      f.input :payout_iban
      f.input :payout_bic
      f.input :payout_reference
      f.input :payout_paypal_email
      f.input :payout_currency, label: 'Paypal currency', as: :select, collection: [['EUR', 'EUR']]
    end
    
    f.inputs "User Group", class: "inputs column-30" do
#      f.input :payout_method, as: :select, collection: Settings::PAYOUT_METHOD
      f.input :memberships, as: :check_boxes, multiple: true, collection: Settings::USER_MEMBERSHIPS.map { |m| [t("user_memberships.#{m}"), m] }
    end

    f.inputs "Notification", class: "inputs column-30" do
      f.input :notify_offers
      f.input :notify_news
      f.input :notify_upcoming
      f.input :notify_improve
    end

    f.inputs "Password Change", class:"inputs column-100" do
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  sidebar 'Customer Support', only: :show do
    table_for user.tickets.order(created_at: :desc).limit(30) do
      column :ticket do |ticket|
        ticket_link(ticket)
      end
    end
  end

  sidebar 'Brands', only: :show do
    table_for user.brands.order(created_at: :desc).limit(30) do
      column :profile do |p|
        link_to("#{p.slug}", admin_brand_path(p))
      end
    end
  end

  sidebar 'Listings', only: :show do
    table_for user.listings.order(created_at: :desc).limit(30) do
      column :title do |p|
        link_to(p.title || "Draft #{p.updated_at}", admin_listing_path(p))
      end
    end
  end

  sidebar "Bookings History", :only => :show do
      attributes_table_for user do
        row("Total Bookings") { user.bookings.approved.count }
        #row("Total Value") { number_to_currency user.bookings.approved.sum(:amount) }
      end
  end


  sidebar 'Listing Bookmarks', only: :show do
    table_for user.listing_votes.order(created_at: :desc).limit(10) do
      column :listing_votes do |v|
        link_to(user.listings.find("#{v.votable_id}").title, admin_listing_path("#{v.votable_id}"))
        #link_to("Show all (#{u.listings.not_draft.count})", admin_listings_path('q[user_id_eq]' => u.id))
      end
    end
  end

  sidebar 'Search Votes', only: :show do
    table_for user.search_votes.order(created_at: :desc).limit(10) do
      column :search_votes do |v|
        #link_to("#{v.votable_type}", admin_search_path("#{v.votable_id}"))
        link_to(user.searches.find("#{v.votable_id}").formatted_address, admin_search_path("#{v.votable_id}"))
      end
    end
  end

  sidebar 'Searches', only: :show do
    table_for user.searches.order(created_at: :desc).limit(10) do
      column :search do |s|
        link_to("#{s.formatted_address}", admin_search_path(s))
      end
    end
  end


end
