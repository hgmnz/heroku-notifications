require 'heroku/api'
require 'heroku'

Excon.defaults[:mock] = true

def api
  Heroku::API.new(:api_key => 'pass', :mock => true)
end

def stub_core
  @stubbed_core ||= begin
    stubbed_core = nil
    any_instance_of(Heroku::Client) do |core|
      stubbed_core = stub(core)
    end
    stub(Heroku::Auth).user.returns("email@example.com")
    stub(Heroku::Auth).password.returns("pass")
    stub(Heroku::Client).auth.returns("apikey01")
    stubbed_core
  end
end

def execute(command_line)
  extend RR::Adapters::RRMethods

  args = command_line.split(" ")
  command = args.shift

  Heroku::Command.load
  object, method = Heroku::Command.prepare_run(command, args)

  any_instance_of(Heroku::Command::Base) do |base|
    stub(base).app.returns("myapp")
  end

  stub(Heroku::Auth).get_credentials.returns(['email@example.com', 'apikey01'])
  stub(Heroku::Auth).api_key.returns('apikey01')

  original_stdin, original_stderr, original_stdout = $stdin, $stderr, $stdout

  $stdin  = captured_stdin  = StringIO.new
  $stderr = captured_stderr = StringIO.new
  $stdout = captured_stdout = StringIO.new

  begin
    object.send(method)
  rescue SystemExit
  ensure
    $stdin, $stderr, $stdout = original_stdin, original_stderr, original_stdout
    Heroku::Command.current_command = nil
  end

  [captured_stderr.string, captured_stdout.string]
end

RSpec.configure do |config|
  config.mock_with :rr
end

load File.join(File.dirname(__FILE__), "..", "init.rb")
