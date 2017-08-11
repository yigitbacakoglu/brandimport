ActiveAdmin.register Booking do
  actions :index, :show, :edit
  menu parent: "Bookings", label: "Bookings", priority: 1
  #menu url: -> {admin_payout_path(:locale => I18n.locale)}, :priority => 1, :label => proc{ I18n.t("admin.payouts") }

  scope :pending do |booking|
    booking.pending
  end

  scope :active do |booking|
    booking.active
  end

  scope :approved do |booking|
    booking.approved
  end

  scope :rejected do |booking|
    booking.rejected
  end

  scope :cancelled do |booking|
    booking.cancelled
  end

  scope :expired do |booking|
    booking.expired
  end

  scope :approved_past do |booking|
    booking.approved.past
  end

  scope :all do |booking|
    booking
  end

  member_action :send_reminder, :method => :post do
    booking = Booking.find(params[:id])
    LandlordMailer.booking_reminder(booking).deliver!
    redirect_to({:action => :show}, {:notice => "Email sent!"})
  end

  action_item(:show, :only => [:show]) do
    if resource.pending?
      link_to "Send reminder to landlord", send_reminder_admin_booking_path(resource), 'data-method' => :post, :title => 'Send a reminder...'
    end
  end


  member_action :create_refund, method: :post do
    refund = Transaction.new(params.require(:transaction).permit(:amount, :currency, :booking_id))
    service = TransactionService.new(refund.booking.transactions.payment.first)
    begin
      service.refund(refund.amount)
      redirect_to({:action => :show}, {:notice => "Refund created!"})
    rescue => e
      redirect_to({:action => :show}, {:alert => "Refund not created! (#{e.message})"})
    end
  end

  member_action :create_payout, method: :post do
    payout = PayoutTransaction.new(params.require(:payout_transaction).permit(:amount, :currency, :booking_id, :user_id, :due_date))
    payout = PayoutService.create(booking: payout.booking, user: payout.user, amount: payout.amount, due_date: payout.due_date)
    if payout.errors.empty?
      redirect_to({:action => :show}, {:notice => "Payout ##{payout.id} transaction (#{payout.kind}) created!"})
    else
      redirect_to({:action => :show}, {:alert => "Payout not created! (#{payout.errors.full_messages.join('\n')})"})
    end
  end

  member_action :cancel, method: :post do
    booking = resource
    booking.update!(params.require(:booking).permit(:cancellation_reason))
    BookingService.new(booking, current_user).cancel_by_admin!
    redirect_to({:action => :show}, {:notice => "Booking cancelled, payment refund/cancelation is queued and should be processed soon."})
  end

  index do
    column :id
    column :listing do |b| link_to(b.listing.title, admin_listing_path(b.listing.id)) end
    column :from
    column :to
    column :amount do |b| "#{b.price.currency} #{humanized_money(b.price)}" end
    column :status
    column :tenant do |b| link_to(b.tenant.display_name, admin_user_path(b.tenant.id)) end
    column :landlord do |b| link_to(b.landlord.display_name, admin_user_path(b.landlord.id)) end
    column :created_at
    column :updated_at
    actions
  end

  filter :from, as: :date_range
  filter :to, as: :date_range
  filter :status, as: :select, collection: proc{ Booking::Status.constants.map{|i| [i, Booking::Status.const_get(i)]} }
  filter :user_email, label: 'Tenant email', as: :string
  filter :listing_user_email, label: 'Landlord email', as: :string
  filter :listing_country_iso3166_alpha2, label: 'Listing Country', as: :select, collection: proc{ Country.all.map{|c| [c.name, c.iso3166_alpha2]}}

  show title: Proc.new{ |b| "Booking for #{b.listing.title}"} do

    panel "Booking request" do
      attributes_table_for booking do
        row :from
        row :to
        row :cancellation_policy do |b| b.cancellation_policy_object.name end
        row :industry
        row :idea
        row :overall_look
        row :your_brand
      end

    end

    panel 'Documents' do
      booking.attachments.each do |a|
        attributes_table_for a do
          row :position
          row :description
          row :locale
          row :attachment_file_name
          row :attachment_file_size
          row :attachment_content_type
          row :attachment_updated_at
          row :file do |i|
            link_to(a.attachment_file_name, a.attachment.url)
          end
          row :preview do |i|
            image_tag i.attachment.url(:normal)
          end
        end
      end
    end

    panel "History" do
      table_for(([booking] + booking.versions.map(&:reify)).flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
        column :updated_at do |t| t.version.nil?? '--': t.version.created_at end
        column :idea
        column :overall_look
        column :industry
        column :your_brand
        column :status
        column :draft
        column :auth_status
        column :auth_error_code
        column :auth_error_message
        column :auth_error_detail
      end
    end

    panel "Tenant Payments" do
      table_for(booking.transactions.map{|t| [t] + t.versions.map(&:reify) }.flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
        column :updated_at
        column :id do |t| transaction_link(t) end
        column :kind
        column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
        column :status
      end
    end

    panel "Payouts" do
      table_for(booking.payout_transactions.map{|t| [t] + t.versions.map(&:reify)}.flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
        column :updated_at
        column :id do |t| payout_transaction_link(t) end
        column :kind
        column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
        column :status
        column :due_date
      end
    end

    panel "Refund Tenant" do
      if booking.amount_refundable && booking.amount_refundable.amount > 0
        render partial: 'refund_form', locals: {booking: booking}
      else
        text_node "Not refundable"
      end
    end

    panel "Create Payout" do
      render 'payout_form', booking: booking
    end

    panel "Cancel" do
      if booking.can_withdraw?
        render 'cancel_form', booking: booking
      end
    end
  end

  sidebar 'Customer Support', only: :show do
    table_for booking.tickets.order(created_at: :desc).limit(30) do
      column :ticket do |ticket|
        ticket_link(ticket)
      end
    end
  end


  sidebar "Details", only: :show do
    attributes_table_for booking do
      row :from
      row :to
      row :listing_version do |b| listing_version_link_for(b) end
      row :brand do |b| text_node auto_link(b.brand, b.brand.nil?? '' : b.brand.name) end
      row :price do |b| "#{b.price.currency} #{humanized_money(b.price)}" end
      row :status
      row :tenant do |b| text_node auto_link(b.tenant, b.tenant.display_name.blank?? b.tenant.email: b.tenant.display_name) end
      row :landlord do |b| text_node auto_link(b.landlord, b.landlord.display_name.blank?? b.landlord.email: b.landlord.display_name) end
      row :tenant_commission do |b| "#{b.tenant_commission.currency} #{humanized_money(b.tenant_commission)}" end
      row :landlord_commission do |b| "#{b.landlord_commission.currency} #{humanized_money(b.landlord_commission)}" end
      row :landlord_vat do |b| "#{b.landlord_vat.currency} #{humanized_money(b.landlord_vat)}" end
      row :tenant_vat do |b| "#{b.tenant_vat.currency} #{humanized_money(b.tenant_vat)}" end
      row :draft
      row :auth_status
      row :auth_error_code
      row :auth_error_message
      row :auth_error_detail
      row :cancellation_reason
      row :reject_reason
    end
  end


end
