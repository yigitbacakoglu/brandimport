ActiveAdmin.register Transaction do
  menu parent: "Payment", label: "Tenant", priority: 1
  actions :index, :show
  config.sort_order = 'created_at_desc'

  scope :payment do |txs|
    txs.authorized_payment
  end

  scope :payment_unauthorized do |txs|
    txs.payment
  end

  scope :refund do |txs|
    txs.refund
  end

  scope :all do |txs|
    txs
  end

  member_action :collect, action: :post do
    PaymentCollector.perform(resource.id)
    redirect_to action: :show
  end

  action_item :show, only: [:show] do
    link_to 'Capture', collect_admin_transaction_path(resource)
  end

  index do
    column :id
    column :kind
    column :status
    column :booking
    column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
    column :created_at
    column :updated_at
    actions

  end

  filter :created_at, as: :date_range

  show do
    columns do
      column do
        panel "Details" do
          attributes_table_for transaction do
            row :id
            row :kind
            row :product
            row :status
            row :booking
            row :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
            row :created_at
            row :updated_at
          end
        end
      end
      column do
        panel "Payment" do
          attributes_table_for transaction do
            row :psp_transaction_id
            row :psp_authorization_code
            row :psp_cc_alias
            row :psp_masked_cc
            row :psp_exp_month
            row :psp_exp_year
            row :psp_method
            row :psp_error_code
            row :psp_error_message
            row :psp_error_detail
          end
        end
      end if transaction.kind == Transaction::Kind::PAYMENT
    end

    panel "History" do
      table_for(([transaction] + transaction.versions.map(&:reify)).flatten.compact.sort_by{ |t| t.updated_at}.reverse) do
        column :updated_at do |t| t.version.nil?? '--': t.version.created_at end
        column :id
        column :kind
        column :status
        column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
      end
    end
  end

end
