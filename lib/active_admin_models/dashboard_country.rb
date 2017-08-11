ActiveAdmin.register_page "Country Dashboard" do

  menu parent: "Dashboard", url: -> {admin_country_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => "Country"

  content :title => "Country" do

    columns do

      column do
        panel "Country Turnover" do
          columns span:4 do
            Admin::DashboardService.new.country_turnover(Date.today.beginning_of_year, Date.today).each do |currency, hash|
              column do
                panel currency do
                  ul do
                    hash.each do |country, amount|
                      li "#{country.name}: #{humanized_money(amount)}"
                    end
                  end
                end
              end
            end
          end
        end
      end

      column do
        panel "Country (listings)" do
          Admin::DashboardService.new.country_listings_count(1, 5).each do |country, count|
            ul do
              li "#{country.name}: #{count}"
            end
          end
        end
      end

    end

  end # content
end
