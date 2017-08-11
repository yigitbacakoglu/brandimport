ActiveAdmin.register Ticket do
  menu parent:"Users"
  permit_params :requester_id, :topic, :listing_id, :booking_id, :subject, :description, :submitter_id
  actions :all, except: [:edit, :update]
  form do |f|
    f.inputs do
      f.input :requester, collection: user_collection, input_html: { onchange: "$.ajax({url:'#{populate_fields_admin_tickets_path}&requester_id=' + $('#ticket_requester_id').val()});" }
      f.input :topic, collection: ticket_topics(Ticket.new), required: true
      f.input :listing, collection: resource.listing ? [[listing_select_label(resource.listing), resource.listing.id]]: []
      f.input :booking, collection: resource.booking ? [[booking_select_label(resource.booking), resource.booking.id]]: []
      f.input :subject
      f.input :description
      f.input :submitter, collection: [current_user], include_blank: false
    end
    f.actions
  end

  controller do
    def create
      super
      service = Zendesk::Service.new
      service.create_ticket(resource)
    end
  end


  collection_action :populate_fields, method: :get do
    user = User.find(params[:requester_id])
    service = CustomerSupportService.for_user(user)
    @listings = service.recent_listings(100)
    @bookings = service.recent_bookings(100)
  end

end
