require "spec_helper"
require "heroku/command/notifications"

module Heroku::Command
  describe Notifications do

    before(:each) do
      stub_core
      api.post_app("name" => "myapp", "stack" => "cedar")
    end

    after(:each) do
      api.delete_app("myapp")
    end

    it "shows an empty list when no notifications available" do
      notification_list = Keikokuc::NotificationList.new(:user     => 'email@example.com',
                                                         :password => '123')
      mock(notification_list).fetch { true }
      notification_list.notifications = []
      any_instance_of(Heroku::Command::Notifications) do |command|
        stub(command).notification_list { notification_list }
      end
      stderr, stdout = execute("notifications")
      stderr.should == ""
      stdout.should == "email@example.com has no notifications.\n"
    end

    it "shows notifications if they exist and marks them as read" do
      notification_list = Keikokuc::NotificationList.new(:user     => 'email@example.com',
                                                         :password => '123')
      mock(notification_list).read_all { true }
      mock(notification_list).fetch { true }
      notification_list.notifications = user_notifications.map do |attributes|
        notification = Keikokuc::Notification.new(attributes)
        notification
      end
      any_instance_of(Heroku::Command::Notifications) do |command|
        stub(command).notification_list { notification_list }
      end
      stderr, stdout = execute("notifications")
      stderr.should == ""
      stdout.should == (<<-END_STDOUT)
=== Notifications for email@example.com (2)
n30: flying-monkey-123
  [info] Database HEROKU_POSTGRESQL_BROWN is over row limits
  More info: https://devcenter.heroku.com/how-to-fix-problem

n31: rising-cloud-42
  [fatal] High OOM rates
  More info: https://devcenter.heroku.com/oom
END_STDOUT
    end

    def user_notifications
        [
          {
            :id               => 1,
            :account_sequence => 'n30',
            :target_name      => 'flying-monkey-123',
            :message          => 'Database HEROKU_POSTGRESQL_BROWN is over row limits',
            :url              => 'https://devcenter.heroku.com/how-to-fix-problem',
            :severity         => 'info'
          },
          {
            :id               => 2,
            :account_sequence => 'n31',
            :target_name      => 'rising-cloud-42',
            :message          => 'High OOM rates',
            :url              => 'https://devcenter.heroku.com/oom',
            :severity         => 'fatal'
          }
        ]
    end
  end
end
