ActiveAdmin.register_page "User Dashboard" do

  menu parent: "Dashboard", url: -> {admin_user_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => "User"

  content :title => "User" do

    columns do

      column do
        panel "Top Landlords (by turnover)" do
          columns do
            Settings::CURRENCY.each do |currency|
              column do
                panel currency do
                  ul do
                    Admin::DashboardService.new.top_landlords_by_turnover(currency, 1, 5).each do |user, amount|
                      li [user_link(user), humanized_money(amount)].join(': ').html_safe
                    end
                  end
                end
              end
            end
          end
        end
      end

      column do
        panel "Top Tenants (by turnover)" do
          columns do
            Settings::CURRENCY.each do |currency|
              column do
                panel currency.iso_code do
                  ul do
                    Admin::DashboardService.new.top_tenants_by_turnover(currency, 1, 5).each do |user, amount|
                      li [user_link(user), humanized_money(amount)].join(': ').html_safe
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
