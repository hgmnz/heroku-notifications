class FakeKeikoku
  def initialize
    @producers = []
    @notifications = []
    @users = []
  end

  def register_producer(opts)
    @producers << opts
  end

  def register_user(opts)
    @users << opts
  end

  def producer_by_api_key(api_key)
    @producers.detect { |p| p[:api_key] == api_key }
  end

  def find_user(api_key)
    @users.detect { |u| u[:api_key] == api_key }
  end

  def find_producer(user, api_key)
    @producers.detect { |p| p[:username] == user && p[:api_key] == api_key }
  end

  def notifications_for_user(email)
    puts "Finding notifications for #{email}"
    puts "All notifications: #{@notifications}"
    @notifications.select do |notification|
      notification.to_hash['account_email'] == email
    end
  end

  def call(env)
    with_rack_env(env) do
      if request_path == '/api/v1/notifications' && request_verb == 'POST'
        if authenticate_producer
          notification = Notification.new({:id => next_id}.merge(request_body))
          @notifications << notification
          [200, { }, [Keikokuc::OkJson.encode({'id' => notification.id})]]
        else
          [401, { }, ["Not authorized"]]
        end
      elsif request_path == '/api/v1/notifications' && request_verb == 'GET'
        if api_key = authenticate_consumer
          notifications = notifications_for_user(api_key).map(&:to_hash)
          [200, { }, [Keikokuc::OkJson.encode(notifications)]]
        else
          [401, { }, ["Not authorized"]]
        end
      elsif request_path =~ %r{/api/v1/notifications/([^/]+)/read} && request_verb == 'POST'
        if current_user = authenticate_consumer
          notification = notifications_for_user(current_user).detect do |notification|
            notification.to_hash['id'].to_s == $1.to_s
          end
          notification.mark_read_by!(current_user)
          [200, {}, [Keikokuc::OkJson.encode({'status' => 'ok'})]]
        else
          [401, { }, ["Not authorized"]]
        end
      end
    end
  end

private
  def rack_env
    @rack_env
  end

  def with_rack_env(rack_env)
    @rack_env = rack_env
    response = yield
  ensure
    @rack_env = nil
    response
  end

  def request_path
    rack_env['PATH_INFO']
  end

  def request_verb
    rack_env['REQUEST_METHOD']
  end

  def request_body
    raw_body = rack_env["rack.input"].read
    rack_env["rack.input"].rewind
    Keikokuc::OkJson.decode(raw_body)
  end

  def authenticate_producer
    auth = Rack::Auth::Basic::Request.new(rack_env)
    if auth.provided? && auth.basic? && creds = auth.credentials
      if find_producer(*creds)
        creds.first
      end
    end
  end

  def authenticate_consumer
    auth = Rack::Auth::Basic::Request.new(rack_env)
    if auth.provided? && auth.basic? && creds = auth.credentials
      # creds looks like [user, password] (technically ['', api_key])
      if user = find_user(creds[-1])
        user[:account_email]
      end
    end
  end

  def next_id
    @@sequence ||= 0
    @@sequence += 1
  end

  class Notification
    def initialize(opts)
      @opts = opts
      opts.each do |key, value|
        self.class.send :define_method, key do
          value
        end
      end
    end

    def to_hash
      @opts.inject({}) { |result, (k, v)| result[k.to_s] = v; result }
    end

    def mark_read_by!(user)
      (@read_by ||= []) << user
    end
  end
end
