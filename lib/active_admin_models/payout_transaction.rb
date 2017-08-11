ActiveAdmin.register PayoutTransaction do
  menu parent: "Payment", label: "Payout Transactions", priority: 1
  actions :index, :show, :edit, :update
  config.sort_order = 'created_at_desc'
  permit_params :status, :due_date

  scope :due do |t|
    t.due
  end

  scope :undue do |t|
    t.undue
  end

  scope :sent do |t|
    t.sent
  end

  scope :completed do |t|
    t.completed
  end

  scope :failed do |t|
    t.failed
  end

  scope :cancelled do |t|
    t.cancelled
  end

  scope :archived do |t|
    t.archived
  end


  batch_action :generate_batch_with do |selection|
    if selection.empty?
      redirect_to(collection_path, :notice => "No payouts selected")
    else
      batch = BankService.new.create_batch(selection)
      redirect_to collection_path, :notice => "Batch payment generated: #{ActionController::Base.helpers.link_to(batch.message_id, download_batch_file_url(batch.id))}".html_safe
    end
  end

  batch_action :complete do |selection|
    if selection.empty?
      redirect_to(collection_path, :notice => "No payouts selected")

    else
      BankService.complete(selection)
      redirect_to collection_path, :notice => "Transactions marked as complete"
    end
  end

  batch_action :fail do |selection|
    if selection.empty?
      redirect_to(collection_path, :notice => "No payouts selected")
    else
      BankService.fail(selection)
      redirect_to collection_path, :notice => "Transactions marked as complete"
    end
  end

  index do
    #selectable_column
    column resource_selection_toggle_cell, class: 'selectable' do |resource|
      #TODO: improve this validation
      if resource.is_due? && !resource.user.payout_country.nil?
        resource_selection_cell resource

      elsif resource.sent?
        resource_selection_cell resource
      end
    end
    column :id
    column :due_date do |p| p.due_date.utc; end
    column :status
    column :kind
    column :amount do |p| "#{p.currency} #{humanized_money p.amount}"; end
    column :booking
    column :country do |p|  p.user.payout_country.try(:iso3166_alpha2); end
    column :payee do |p| p.user.payout_payee_name; end
    column :iban do |p| p.user.payout_iban; end
    column :bic do |p| p.user.payout_bic; end
    column :reference do |p| p.user.payout_reference; end
    actions
  end

  filter :due_date, as: :date_range
  filter :currency, as: :select, collection: proc{ Settings::CURRENCY.map{|c| [c.name, c.iso_code]} }
  filter :amount_cents
  filter :status, as: :select
  filter :kind, as: :select
  filter :booking_from, as: :date_range
  filter :booking_to, as: :date_range
  filter :user_email, label: 'Payee email', as: :string
  filter :booking_listing_country_iso3166_alpha2, label: 'Listing Country', as: :select, collection: proc{ Country.all.map{|c| [c.name, c.iso3166_alpha2]}}

  show do
    columns do
      column do
        panel "Details" do
          attributes_table_for payout_transaction do
            row :id
            row :status
            row :kind
            row :booking
            row :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
            row :due_date
            row :created_at
            row :updated_at
          end
        end
      end
    end

    panel "History" do
      table_for(([payout_transaction] + payout_transaction.versions.map(&:reify)).flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
        column :updated_at do |t| t.version.nil?? '--': t.version.created_at end
        column :id
        column :status
        column :due_date
        column :booking
        column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :status, collection: payout_status_collection, include_blank: false
      f.input :due_date, as: :datetime_picker
    end
    f.actions
  end
end
