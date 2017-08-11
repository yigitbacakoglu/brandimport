ActiveAdmin.register Mailbox::Message, as: "Message" do
  menu parent: "Users", label: "Messages", priority: 1000
  actions :index, :show
  #config.batch_actions = false
  config.sort_order = 'updated_at_desc'

  index do
    column :id
    column :sender do |n| n.sender.display_name if n.sender end
    #do not show sender as one of the recipients
    column :recipients do |n| n.recipients.select{|u| u != n.sender }.map{|u| link_to("#{u.display_name}(##{u.id})", admin_user_path(u.id)) }.join(', ').html_safe end
    column :subject
    column :body
    column t('admin.conversations.conversation') do |n| link_to "View", admin_messages_path('q[conversation_id_eq]' => n.conversation_id) if n.conversation_id end
    column :created_at
    actions
  end

  filter :body
  filter :subject
  filter :created_at
  filter :receipts_receiver_of_User_type_email, as: :string, label: 'Recipient Email'
  filter :receipts_receiver_of_User_type_first_name, as: :string, label: 'Recipient First Name'
  filter :receipts_receiver_of_User_type_last_name, as: :string, label: 'Recipient Last Name'
  filter :receipts_receiver_of_User_type_company, as: :string, label: 'Recipient Company'

  show title: "Message" do |n|
    panel "Details" do
      attributes_table_for n do
        row :id
        row :sender do |n| n.sender.display_name if n.sender end
        row :subject
        row :body
        row :recipients do |n| n.recipients.select{|u| u != n.sender }.map{|u| link_to("#{u.display_name}(##{u.id})", admin_user_path(u.id)) }.join(', ').html_safe end
        row :created_at
      end
    end
  end

end
