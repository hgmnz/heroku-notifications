require 'rest-client'
require 'keikokuc/okjson'
require 'timeout'

# Internal: Handles HTTP requests/responses to the keikoku API
#
# This class is meant to be used internally by Keikokuc
class Keikokuc::Client
  include HandlesTimeout

  InvalidNotification = Class.new
  Unauthorized = Class.new

  attr_accessor :producer_username, :api_key

  def initialize(opts = {})
    @api_key           = opts[:api_key]
    @producer_username = opts[:producer_username]
  end

  # Internal: posts a new notification to keikoku
  #
  # attributes - a hash containing notification attributes
  #
  # Examples
  #
  #   client = Keikokuc::Client.new(producer_api_key: 'abcd')
  #   response, error = client.post_notification(message: 'hello')
  #
  # Returns
  #
  # two objects:
  #   The response as a hash
  #   The error if any (nil if no error)
  #
  # Possible errors include:
  #
  # * `Client::Timeout` if the request takes longer than 5 seconds
  # * `Client::InvalidNotification` if the response indicates
  #   invalid notification attributes
  # * `Client::Unauthorized` if API key auth fails
  def post_notification(attributes)
    begin
      response = notifications_api.post(encode_json(attributes))
      [parse_json(response), nil]
    rescue RestClient::UnprocessableEntity => e
      [parse_json(e.response), InvalidNotification]
    rescue RestClient::Unauthorized
      [{}, Unauthorized]
    end
  end
  handle_timeout :post_notification

  # Internal: gets all active notifications for a user
  #
  # Examples
  #
  #   client = Keikokuc::Client.new(api_key: 'api-key')
  #   response, error = client.get_notifications
  #
  # Returns
  #
  # two objects:
  #   The response as a hash
  #   The error if any (nil if no error)
  #
  # Possible errors include:
  #
  # * `Client::Timeout` if the request takes longer than 5 seconds
  # * `Client::Unauthorized` if HTTP Basic auth fails
  def get_notifications
    begin
      response = notifications_api.get
      [parse_json(response), nil]
    rescue RestClient::Unauthorized
      [{}, Unauthorized]
    end
  end
  handle_timeout :get_notifications

  # Public: Marks a notification as read
  #
  # remote_id - the keikoku id for the notification to mark as read
  #
  # two objects:
  #   The response as a hash
  #   The error if any (nil if no error)
  #
  # Possible errors include:
  #
  # * `Client::Timeout` if the request takes longer than 5 seconds
  # * `Client::Unauthorized` if HTTP Basic auth fails
  def read_notification(remote_id)
    begin
      response = notifications_api["/#{remote_id}/read"].post ''
      parsed_response = parse_json(response)
      [parsed_response, nil]
    rescue RestClient::Unauthorized
      [{}, Unauthorized]
    end
  end
  handle_timeout :read_notification

private
  def notifications_api # :nodoc:
    @notifications_api ||= RestClient::Resource.new(
      api_url,
      :user     => producer_username || '',
      :password => api_key
    )
  end

  def api_url # :nodoc:
    "https://keikoku.herokuapp.com/api/v1/notifications"
  end

  def encode_json(hash) # :nodoc:
    Keikokuc::OkJson.encode(stringify_hash_keys(hash))
  end

  def parse_json(data) # :nodoc:
    symbolize_keys(Keikokuc::OkJson.decode(data)) if data
  end

  def symbolize_keys(object) # :nodoc:
    case object
    when Hash
      symbolize_hash_keys(object)
    when Array
      object.map { |item| symbolize_hash_keys(item) }
    end
  end

  def symbolize_hash_keys(hash)
    hash.inject({}) do |result, (k, v)|
      result[k.to_sym] = v
      result
    end
  end

  def stringify_hash_keys(hash)
    hash.inject({}) do |result, (k, v)|
      result[k.to_s] = v
      result
    end
  end
end
