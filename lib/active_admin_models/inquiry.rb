ActiveAdmin.register Inquiry do
  actions :index, :show
  menu parent: "Bookings", label: "Inquiries", priority: 1
  #menu url: -> {admin_payout_path(:locale => I18n.locale)}, :priority => 1, :label => proc{ I18n.t("admin.payouts") }

  index do
    column :id
    column :listing do |i| link_to(i.listing.title, admin_listing_path(i.listing.id)) end
    column :from
    column :to
    column :created_at
    actions
  end

end
