ActiveAdmin.register_page "Newest Dashboard" do

  menu parent: "Dashboard", url: -> {admin_newest_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => "Newest"

  content :title => "Newest" do

    columns do

      column do
        panel "Newest users" do
          ul do
            Admin::DashboardService.new.newest_users(1, 5).each do |user|
              li user_link(user)
            end
          end
        end
      end

      column do
        panel "Newest listings" do
          ul do
            Admin::DashboardService.new.newest_listings(1, 5).each do |listing|
              li listing_link(listing)
            end
          end
        end
      end

    end


  end # content
end
