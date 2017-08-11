ActiveAdmin.register Brand do
  menu parent: "Users", label: "Brands", priority: 2
  config.sort_order = 'updated_at_desc'
  config.batch_actions = false

  before_filter do
    params.permit!
  end

  index do
    column :id
    column :name
    column :title
    column :industry
    column :overall_look
    column :slug
    column :updated_at

    #column :title do |t| t.brand.try(:title) end
    #column :description do |t| t.brand.try(:description) end
    #column :currency do |t| t.brand.try(:currency) end
    #column :employee_count do |t| t.brand.try(:employee_count) end
    #column :year_founded do |t| t.brand.try(:year_founded) end
    #column :brand_slug do |t| t.brand.try(:slug) end
    #column :facebook_id do |t| t.brand.try(:facebook_id) end
    #column :twitter_id do |t| t.brand.try(:twitter_id) end
    #column :instagram_id do |t| t.brand.try(:instagram_id) end

    #column :prices_from do |t| "#{t.brand.try(:currency)} #{humanized_money(t.brand.try(:prices_from))}" end
    #column :prices_to do |t| "#{t.brand.try(:currency)} #{humanized_money(t.brand.try(:prices_to))}" end
    #column :tags do |t| t.brand.try(:tags) end
    column :user do |t| link_to(t.user.display_name, admin_user_path(t.user_id)) if t.user_id end
    #column :is_premium do |t| t.brand.try(:is_premium) end
    #column :valid_until do |t| t.brand.try(:valid_until) end
    #column :reminder_sent_at do |t| t.brand.try(:reminder_sent_at) end
    actions
  end

  form html: {multipart: true} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :user, collection: user_collection
      f.input :title
      f.input :description
      f.input :employee_count
      f.input :year_founded
      f.input :twitter_id
      f.input :instagram_id
      f.input :facebook_id
      f.input :currency, collection: Settings::CURRENCY_CODES, include_blank: false
      f.input :prices_from, input_html: { value: number_with_precision(f.object.prices_from, precision: 2) }
      f.input :prices_to, input_html: { value: number_with_precision(f.object.prices_to, precision: 2) }
      f.input :tags, as: :check_boxes, collection: admin_enum_collection(Settings::BRAND_TAGS, "enum.brand")
      f.input :is_premium
      f.input :valid_until, as: :datepicker
      f.input :logo
      f.input :image
    end

    f.inputs "Brand Images" do
      f.has_many :brand_images, allow_destroy: true do |p|
        p.input :attachment, :hint => p.object && p.object.attachment.exists?? f.template.link_to(p.object.attachment_file_name, p.object.attachment.url): ''
      end
    end

    f.inputs "Brand Documents" do
      f.has_many :brand_documents, allow_destroy: true do |p|
        p.input :attachment, :hint => p.object && p.object.attachment.exists?? f.template.link_to(p.object.attachment_file_name, p.object.attachment.url): ''
      end
    end

    f.actions
  end

  show do
    panel '' do
      attributes_table_for brand do
        row :title
        row :description
        row :employee_count
        row :year_founded
        row :prices_from do |b| "#{b.try(:currency)} #{humanized_money(b.try(:prices_from))}" end
        row :prices_to do |b| "#{b.try(:currency)} #{humanized_money(b.try(:prices_to))}" end
        row :tags
        row :is_premium
        row :valid_until
        row :logo do |b|
          image_tag b.logo.url(:medium)
        end
        row :image do |b|
          image_tag b.image.url(:thumb)
        end
      end
    end
    columns do
      column do
        panel "Brand Images" do
          brand.brand_images.each do |a|
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
              row :image_thumb do |i|
                image_tag i.attachment.url(:thumb)
              end
            end
          end
        end
      end

      column do
        panel "Brand Documents" do
          brand.brand_documents.each do |a|
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
      end
    end
  end
  
  #controller do
  #  before_filter only: :update do
  #    params[:brand][:industry].delete_if(&:blank?) if params[:brand_profile] && params[:brand_profile][:industry]
  #  end
  #end

end
