ActiveAdmin.register_page "Turnover Dashboard" do

  menu parent: "Dashboard", url: -> {admin_turnover_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => "Turnover"

  content :title => "Turnover" do

    columns do

      column do
        panel "Turnover (Today)" do
          ul do
            Admin::DashboardService.new.turnover_by_period(Date.today, Date.today).each do |currency, amount|
              li money(amount)
            end
          end
        end
      end

      column do
        panel "Turnover (last 7 days)" do
          ul do
            Admin::DashboardService.new.turnover_by_period(Date.today-6.days, Date.today).each do |currency, amount|
              li money(amount)
            end
          end
        end
      end

    end


  end # content
end
