require 'keikokuc'
require 'heroku/command/base'
require 'heroku/api'

class Heroku::Command::Notifications < Heroku::Command::Base

  # notifications
  #
  # Show all notifications
  def index
    if notification_list.fetch
      if notification_list.empty?
        display("No notifications.")
      else
        display(notification_list.map do |notification|
          attachment, app = attachment_for(notification.target_name)
          display_header("#{attachment} on app #{app}")
          out = "[#{notification.severity}] #{notification.message}\n"
          out += "More info: #{notification.url}\n"
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

  def attachment_for(resource_name)
    response = Heroku::Auth.api.request(:method => 'GET', :path => "/resources/#{resource_name}")
    if response.status == 200
      attachment = response.body['attachments'].first
      [attachment["name"], attachment["app"]["name"]]
    end
  end
end
