ActiveAdmin.register Event do

  menu url: -> { admin_events_path(:scope => :awaiting_approval) }, label: "Events"

  permit_params :title, :headline, :description, :url, :admin_comment, :state, :city_name, :attachments, :starts_at, :ends_at, :user_id,
    tags: [],
    attachments_attributes: [:id, :attachment, :_destroy]

  index do
    column :id
    column :title
    column :headline
    column :user do |e| text_node user_link(e.user) end
    #column :description
    column :state
    column :starts_at
    column :ends_at
    column :created_at
    column :updated_at
    actions
  end

  form html: {multipart: true} do |f|
    f.inputs do
      f.input :user, collection: user_collection
      f.input :title
      f.input :headline
      f.input :user, collection: user_collection
      f.input :description
      f.input :tags, as: :check_boxes, collection: admin_enum_collection(Settings::EVENT_TAGS, "enum.event")
      f.input :address
      f.input :city_name
      f.input :latitude
      f.input :longitude
      f.input :url
      f.input :starts_at
      f.input :ends_at
    end

    f.inputs "Review" do
      f.input :state, :as => :select, :collection => Event::STATES
      f.input :admin_comment
    end

    f.inputs "Images" do
      f.has_many :attachments, allow_destroy: true do |p|
        p.input :attachment, :hint => p.object && p.object.attachment.exists? ? f.template.image_tag(p.object.attachment.url(:normal)) : ''
      end
    end

    f.semantic_errors(*f.object.errors.keys)
    f.actions
  end

  scope :past do |events|
    events.past
  end

  scope :draft do |events|
    events.current.draft
  end

  scope :awaiting_approval do |events|
    events.current.awaiting_approval
  end

  scope :approved do |events|
    events.current.approved
  end

  scope :rejected do |events|
    events.current.rejected
  end

  sidebar "Awaiting approval", only: :show, if: Proc.new{ resource.awaiting_approval? } do
    render partial: 'review_form', locals: {event: event}
  end

  sidebar "Review", only: :show, if: Proc.new{ resource.reviewed? } do
    attributes_table_for event do
      row :state do |event| t("event.states.#{event.state}") end
      row :admin_comment
    end
  end

  member_action :review, method: :put do
    event = Event.find(params[:id])
    event_params = params.require(:event).permit(:state, :admin_comment)
    event.update_attributes(event_params)
    UserMailer.send("event_#{event.state}", event).deliver!
    redirect_to({:action => :show}, {:notice => "Event reviewed!"})
  end

  controller do
    before_filter only: :update do
      params[:event][:tags].delete_if(&:blank?) if params[:event] && params[:event][:tags]
    end
  end

end
