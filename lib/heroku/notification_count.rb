module Heroku
  class NotificationCount
    def fetch
      @thread = Thread.new do
        list = Keikokuc::NotificationList.new(
          :api_key => Heroku::Auth.password
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
