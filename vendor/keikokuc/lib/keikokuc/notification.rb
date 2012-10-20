# Public: Encapsulates a keikoku notification
#
# This is the entry point for dealing with notifications
#
# Examples
#
#   notification = Keikokuc::Notification.new(message: 'hello',
#                                             severity: 'info',
#                                             target_name: 'sunny-skies-42'
#                                             producer_api_key: 'abcd')
#   if notification.publish
#     # persist notification
#   else
#     # handle error
#   end
#
class Keikokuc::Notification
  attr_accessor :message, :url, :severity,
                :target_name, :account_email,
                :producer_api_key, :remote_id,
                :errors, :read_at, :account_sequence

  # Public: Initialize a notification
  #
  # opts - a hash of attributes to be set on constructed object
  #
  # Examples
  #
  #   notification = Keikokuc::Notification.new(message: 'hello')
  #
  # All keys on the attr_accessor list will be set
  def initialize(opts = {})
    @message          = opts[:message]
    @url              = opts[:url]
    @severity         = opts[:severity]
    @target_name      = opts[:target_name]
    @account_email    = opts[:account_email]
    @producer_api_key = opts[:producer_api_key]
    @remote_id        = opts[:remote_id]
    @errors           = opts[:errors]
    @read_at          = opts[:read_at]
    @account_sequence = opts[:account_sequence]
    @client           = opts[:client]
  end

  # Public: publishes this notification to keikoku
  #
  # This method sets the `remote_id` attribute if it succeeds.
  # If it fails, the `errors` hash will be populated.
  #
  # Returns a boolean set to true if publishing succeeded
  def publish
    hash = to_hash
    hash.delete(:client)
    response, error = client.post_notification(hash)
    if error.nil?
      self.remote_id = response[:id]
      self.errors = nil
    elsif error == Keikokuc::Client::InvalidNotification
      self.errors = response[:errors]
    end
    error.nil?
  end

  # Public: marks this notification as read on keikoku
  #
  # Marks the notification as read, after which it will
  # no longer be displayed to any consumer for this user
  #
  # Returns a boolean set to true if marking as read succeeded
  def read
    response, error = client.read_notification(remote_id)
    if error.nil?
      self.read_at = response[:read_at]
    end
    error.nil?
  end

  # Public: whether this notification is marked as read by this user
  #
  # Returns true if the user has marked this notification as read
  def read?
    !!@read_at
  end

  # Internal: coerces this notification to a hash
  #
  # Returns this notification's attributes as a hash
  def to_hash
    {
      :message          => @message,
      :url              => @url,
      :severity         => @severity,
      :target_name      => @target_name,
      :account_email    => @account_email,
      :producer_api_key => @producer_api_key,
      :remote_id        => @remote_id,
      :errors           => @errors,
      :read_at          => @read_at,
      :account_sequence => @account_sequence,
      :client           => @client
    }
  end

  def client # :nodoc:
    @client ||= Keikokuc::Client.new(:producer_api_key => producer_api_key)
  end
end
