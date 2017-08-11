ActiveAdmin.register_page "Listing Dashboard" do

  menu parent: "Dashboard", url: -> {admin_listing_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => "Listing"

  content :title => "Listing" do

    columns do

      column do
        panel "Top Listings (by no of bookings)" do
          ul do
            Admin::DashboardService.new.top_listings_by_bookings(1, 5).each do |listing, count|
              li [listing_link(listing).html_safe, count].join(':').html_safe
            end
          end
        end
      end

      column span: 3 do
        panel "Top Listings (by turnover)" do
          columns do
            Settings::CURRENCY.each do |currency|
              column do
                panel currency do
                  ul do
                    Admin::DashboardService.new.top_listings_by_turnover(currency, 1, 5).each do |listing, amount|
                      li [listing_link(listing).html_safe, money(amount)].join(' ').html_safe
                    end
                  end
                end
              end
            end
          end
        end
      end

    end

  end # content
end
