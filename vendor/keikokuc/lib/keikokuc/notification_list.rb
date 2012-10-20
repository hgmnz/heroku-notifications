# Public: collection of keikoku notifications
#
# This class encapsulates Keikoku::Notification objects
# as a collection.
#
# It includes the Enumerable module, so `map`, `detect`,
# and friends can be used.
#
# Examples
#
#   notifications = Keikokuc::NotificationList.new(user:    'user@example.com',
#                                                  api_key: 'abcd')
#   if notifications.fetch
#     notifications.each do |notification|
#       puts notification.inspect
#     end
#   else
#     # handle error
#   end
class Keikokuc::NotificationList
  include Enumerable

  attr_accessor :user, :password

  # Public: Initializes a NotificationList
  #
  # opts - options hash containing attribute values for the object
  #        being constructed accepting the following three keys:
  #  user - the heroku account's email (required)
  #  password - the heroku account's password (required)
  #  client - the client, used for DI in tests
  def initialize(opts)
    @user          = opts.fetch(:user)
    @password      = opts.fetch(:password)
    @client        = opts[:client]
    @notifications = []
  end

  # Public: fetches notifications for the provided user
  #
  # Sets notifications to a set of `Notification` objects
  # accessible via methods in Enumerable
  #
  # Returns a boolean set to true if fetching succeeded
  def fetch
    result, error = client.get_notifications
    if error.nil?
      @notifications = result.map do |attributes|
        attributes.merge!(:client    => client,
                          :remote_id => attributes.delete(:id))
        Keikokuc::Notification.new(attributes)
      end
    end

    error.nil?
  end

  # Public: marks all notifications as read
  #
  # This is a convenience method for marking all underlying notifications
  # as read.
  #
  # Returns a Boolean set to true if all notifications were read successfully.
  def read_all
    self.inject(true) { |result, notification| result && notification.read }
  end

  # Public: the number of notifications
  #
  # Returns an Integer set to the number of notifications
  def size
    @notifications.size
  end

  # Public: yields each Notification
  #
  # Yields every notification in this collection
  def each
    @notifications.each { |n| yield n }
  end

  # Public: wether there are no notifications
  #
  # Returns a Boolean set to true if there is at least one notification
  def empty?
    self.size.zero?
  end

  # Internal: assigns notifications
  #
  # Allows notifications to be injected, useful in tests
  def notifications=(new_notification)
    @notifications = new_notification
  end

private
  def client # :nodoc:
    @client ||= Keikokuc::Client.new(:user     => user,
                                     :password => password)
  end
end
