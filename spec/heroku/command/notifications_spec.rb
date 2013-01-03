require "spec_helper"
require "heroku/command/notifications"

module Heroku::Command
  describe Notifications do

    before do
      stub_core
      api.post_app("name" => "myapp", "stack" => "cedar")
      Excon.stub({:path => '/resources/flying-monkey-123'},
                 { :status => 200,
                   :body => { "billing_app" => { "name" => "app1" }, "attachments" => [{"name" => "HEROKU_POSTGRESQL_BLACK", "app" => { "name" => "app1" }}] }})
    end

    after do
      api.delete_app("myapp")
      Excon.stubs.shift
    end

    it "shows an empty list when no notifications available" do
      notification_list = Keikokuc::NotificationList.new(:api_key => '123')
      mock(notification_list).fetch { true }
      notification_list.notifications = []
      any_instance_of(Heroku::Command::Notifications) do |command|
        stub(command).notification_list { notification_list }
      end
      stderr, stdout = execute("notifications")
      stderr.should == ""
      stdout.should == "No notifications.\n"
    end

    it "shows notifications if they exist and marks them as read" do
      notification_list = Keikokuc::NotificationList.new(:api_key => '123')
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
=== HEROKU_POSTGRESQL_BLACK on app app1
[info] Database HEROKU_POSTGRESQL_BROWN is over row limits
More info: https://devcenter.heroku.com/how-to-fix-problem
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
          }
        ]
    end
  end
end
