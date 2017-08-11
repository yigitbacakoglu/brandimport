ActiveAdmin.register Landlord do
  menu parent: "Listings", url: -> { admin_landlords_path()}, label: "Landlords", priority: 2
  permit_params :company, :first_name, :last_name, :address_1, :address_2, :zip, :city, :phone, :country



  form do |f|
    f.inputs do
      f.input :company
      f.input :first_name
      f.input :last_name
      f.input :address_1
      f.input :address_2
      f.input :zip
      f.input :city
      f.input :phone
      f.input :country, as: :string
    end
    f.actions
  end
end
