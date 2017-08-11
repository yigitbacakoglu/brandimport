ActiveAdmin.register Domain do
  menu parent: "Settings"
  permit_params :name, :country_id
end
