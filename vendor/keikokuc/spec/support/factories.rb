module Factories
  def build_notification(opts = {})
    defaults = {
      :message       => 'Your database is over limits',
      :target_name   => 'cloudy-skies-243',
      :severity      => 'info',
      :account_email => 'harold@heroku.com'
    }
    Keikokuc::Notification.new(defaults.merge(opts))
  end

  def build_notification_list(opts = {})
    defaults = {
      :api_key => 'api-key'
    }
    Keikokuc::NotificationList.new(defaults.merge(opts))
  end
end
