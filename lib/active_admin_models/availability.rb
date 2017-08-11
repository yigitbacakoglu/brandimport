ActiveAdmin.register Availability do
  belongs_to :listing
  navigation_menu :listing
  permit_params :starts_at, :ends_at, :is_available, :rent_per_day, :rent_per_week, :rent_per_month

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :starts_at
      f.input :ends_at
      f.input :is_available, label: "Available?"
    end
    f.inputs "Special Prices" do
      f.input :rent_per_day
      f.input :rent_per_week
      f.input :rent_per_month
    end

    f.actions
  end
end
