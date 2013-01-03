require 'spec_helper'

module Keikokuc
  describe Notification, '#publish' do
    it 'publishes to keikoku and stores an id' do
      fake_client = double
      fake_client.
        should_receive(:post_notification).with do |args|
          expect(args[:message]).to eq('hello')
          expect(args[:account_email]).to eq('harold@heroku.com')
        end.and_return([{ :id => 1 }, nil])

      notification = build_notification(:message       => 'hello',
                                        :account_email => 'harold@heroku.com',
                                        :client        => fake_client)

      result = notification.publish
      expect(result).to be_true

      expect(notification.remote_id).to eq(1)
    end

    it 'returns false when publishing fails and stores errors' do
      fake_client = double
      fake_client.
        should_receive(:post_notification).with do |args|
          expect(args[:message]).to be_nil
        end.
        and_return([{ :errors => { :attributes => { :message => ['is not present'] }}},
                   Keikokuc::Client::InvalidNotification])

      notification = build_notification(:message => nil,
                                        :client  => fake_client)

      result = notification.publish
      expect(result).to be_false

      expect(notification.remote_id).to be_nil
      expect(notification.errors[:attributes][:message]).to eq(['is not present'])
    end

    it 'stores attributes as instance vars' do
      notification = Notification.new(:message => 'foo')
      expect(notification.message).to eq('foo')
    end
  end

  describe Notification, '#read' do
    it 'marks as read to keikoku' do
      fake_client = double

      fake_client.should_receive(:read_notification).
        with('1234').
        and_return([{'status' => 'ok'}, nil])

      notification = Notification.new(:remote_id => '1234', :client => fake_client)

      result = notification.read
      expect(result).to be_true
    end

    it 'handles errors' do
      fake_client = double
      fake_client.stub(:read_notification).
        with('1234').
        and_return([{}, :some_error])

      notification = Notification.new(:remote_id => '1234',
                                      :client    => fake_client)

      result = notification.read
      expect(result).to be_false
    end
  end

  describe Notification, '#client' do
    it 'defaults to a properly constructer Keikokuc::Client' do
      notification = build_notification(:producer_api_key => 'fake-api-key', :producer_username => 'heroku-postgres')
      expect(notification.client).to be_kind_of(Keikokuc::Client)
      expect(notification.client.api_key).to eq('fake-api-key')
      expect(notification.client.producer_username).to eq('heroku-postgres')
    end

    it 'can be injected' do
      notification = Notification.new(:client => :foo)
      expect(notification.client).to eq(:foo)
    end
  end
end
