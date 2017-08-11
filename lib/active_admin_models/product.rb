ActiveAdmin.register Product do
  menu url: -> { admin_products_path }, label: "Products", priority: 3
  config.sort_order = 'updated_at_desc'


  controller do
    def permitted_params
      params.permit!
    end
  end

  filter :kind, as: :select

  scope :all do |products|
    products
  end

  scope :premium_listing do |products|
    products.premium_listing
  end


  member_action :renew, action: :post do
    result = Product::RenewalService.new(product: resource).process(automatic: false)
    redirect_to resource_path, notice: "Result: #{result}"
  end

  member_action :cancel, action: :post do
    result = Product::CancelService.new(product: resource).process(status_reason: 'cancelled by admin.')
    redirect_to resource_path, notice: "Product cancelled, it's valid until #{resource.valid_until}"
  end

  show do
    panel :Transactions do
      table_for product.transactions.order(updated_at: :desc) do
        column :id do |t| transaction_link(t) end
        column :updated_at
        column :status
        column :amount do |t| "#{t.amount.currency} #{humanized_money(t.amount)}" end
        column :ref_no
        column :psp_error_code
        column :psp_error_message
        column :psp_error_detail
        column :try_no
        column :next_retry_at
      end
    end

    panel 'Payment Method' do
      table_for product.payment_method do
        column :psp_authorization_code
        column :psp_cc_alias
        column :psp_masked_cc
        column :psp_exp_month
        column :psp_exp_year
        column :psp_method
      end

    end

    panel :Details do
      attributes_table_for product do
        row :user
        row :status
        row :status_reason
        row :valid_until
        row :price
        row :kind
      end
    end

  end

  #index do
  #end

  form do |f|
    f.inputs do
      f.input :status
      f.input :valid_until
      f.input :price, input_html: { value: number_with_precision(f.object.price, precision: 2),
                                    data: {
                                        role: 'money',
                                        a_sep: f.object.price.currency.thousands_separator,
                                        a_dec: f.object.price.currency.decimal_mark
                                    }
      }
      f.input :currency, collection: currency_collection, include_blank: false
      f.input :payment_method_id, label: :payment_method, as: :select, collection: resource.user.payment_methods.collect{|pm| ["#{pm.psp_method} #{pm.psp_masked_cc} #{pm.psp_exp_month}/#{pm.psp_exp_year}", pm.id]}, include_blank: false
    end
    f.actions
    render partial: 'currency_js'
  end

  action_item :support, only: :show do
    link_to 'Renew Subscription', renew_admin_product_path(resource)
  end

  action_item :support, only: :show do
    link_to 'Cancel Subscription', cancel_admin_product_path(resource)
  end

  sidebar "User", only: :show, if: Proc.new{ resource.user } do
    attributes_table_for product.user do
      row :user do |user|  user_link(user) end
    end
  end

  sidebar "Listing", only: :show, if: Proc.new{ resource.listing } do
    attributes_table_for product.listing do
      row :listing do |listing|  listing_link(listing) end
    end
  end

  sidebar "Brand", only: :show, if: Proc.new{ resource.brand } do
    attributes_table_for product.brand do
      # XXX product/brand pending.
    end
  end

  # sidebar "Invitation", only: :show, if: Proc.new{ resource.invitation_id } do
  #   attributes_table_for product.invitation do
  #     # XXXX product/invitation pending.
  #   end
  # end

end
