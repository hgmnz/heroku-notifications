module Heroku
  class NotificationCount
    # def initialize(notification_list_class = Keikokuc::NotificationList)
    #   @notification_list_class = notification_list_class
    # end

    def fetch
      @thread = Thread.new do
        list = Keikokuc::NotificationList.new(
          :user     => Heroku::Auth.user,
          :password => Heroku::Auth.password
        )
        list.fetch
        list.count
      end
    end

    def done?
      !@thread.alive?
    end

    def has_notifications?
      @thread.value > 0
    end
  end
end
