require 'keikokuc'
require 'heroku/command/base'

class Heroku::Command::Notifications < Heroku::Command::Base

  # notifications
  #
  # Show all notifications
  def index
    if notification_list.fetch
      if notification_list.empty?
        display("#{current_user} has no notifications.")
      else
        display_header("Notifications for #{current_user} (#{notification_list.size})", true)
        display(notification_list.map do |notification|
          out = "#{notification.account_sequence}: #{notification.target_name}\n"
          out += "  [#{notification.severity}] #{notification.message}\n"
          out += "  More info: #{notification.url}\n"
          out
        end.join("\n"))
        notification_list.read_all
      end
    end
  end

private
  def current_user # :nodoc:
    Heroku::Auth.user
  end

  def notification_list # :nodoc:
    @notification_list ||= Keikokuc::NotificationList.new(
      :user     => current_user,
      :password => Heroku::Auth.password
    )
  end
end
