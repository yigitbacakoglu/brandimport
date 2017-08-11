ActiveAdmin.register_page "Dashboard" do

  menu url: -> {admin_dashboard_path(:locale => I18n.locale)}, :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    div :class => "blank_slate_container", :id => "dashboard_default_message" do
      span :class => "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    columns do

      column do
        panel "Due Payouts" do
          ul do
            Admin::DashboardService.new.due_payouts.each do |currency, amount|
              li money(amount)
            end
          end
        end
      end

      column do
        panel "Pending Listings" do
          ul do
            Admin::DashboardService.new.listings_pending_approval.each do |listing|
              li listing_link(listing)
            end
          end
        end
      end

      column do
        panel "Pending ID verifications" do
          ul do
            User.pending_id_verification.limit(30).each do |user|
              li do
                "#{user_edit_link(user)}: #{link_to(user.id_photo.original_filename, user.id_photo.url)}".html_safe
              end
            end
          end
        end
      end

      column do
        panel "Pending Phone verifications" do
          ul do
            User.pending_phone_verification.limit(30).each do |user|
              li do
                "#{user_edit_link(user)}: Phone:#{user.phone} (#{user.city} #{user.country.try(:name)})".html_safe
              end
            end
          end
        end
      end

      column do
        panel "Pending Events" do
          ul do
            Admin::DashboardService.new.events_awaiting_approval.each do |event|
              li event_link(event)
            end
          end
        end
      end
    end

  end # content
end
