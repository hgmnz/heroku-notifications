Heroku::Command.module_eval do
  class << self
    alias :original_run :run

    def run(command, arguments=[])
      check_notifications = command != 'notifications'
      if check_notifications
        counter = Heroku::NotificationCount.new
        counter.fetch
      end

      original_run(command, arguments)

      if check_notifications
        if counter.done? && counter.has_notifications?
          puts "\nUnread notifications available. Run `heroku notifications` to view them."
        end
      end
    end
  end
end
