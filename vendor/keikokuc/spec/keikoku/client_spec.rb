require 'spec_helper'
require 'sham_rack'
module Keikokuc
  shared_context 'client specs' do
    let(:fake_keikoku) { FakeKeikoku.new }
    after { ShamRack.unmount_all }
  end

  describe Client, '#post_notification' do
    include_context 'client specs'

    it 'publishes a new notification' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_producer({:api_key => 'abc', :username => 'heroku-postgres'})
      client = Client.new(:api_key => 'abc', :producer_username => 'heroku-postgres')
      result, error = client.post_notification(:message  => 'hello',
                                               :severity => 'info')
      expect(result[:id]).not_to be_nil
      expect(error).to be_nil
    end

    it 'handles invalid notifications' do
      ShamRack.at('keikoku.herokuapp.com', 443) do |env|
        [422, {}, StringIO.new(OkJson.encode({ 'errors' => 'srorre' }))]
      end

      response, error = Client.new.post_notification({})
      expect(error).to be Client::InvalidNotification
      expect(response[:errors]).to eq('srorre')
    end

    it 'handles authentication failures' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_producer({:api_key => 'abc', :username => 'heroku-postgres'})
      client = Client.new(:api_key => 'bad one', :producer_username => 'heroku-postgres')
      result, error = client.post_notification(:message  => 'hello',
                                               :severity => 'info')
      expect(result[:id]).to be_nil
      expect(error).to eq Client::Unauthorized
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:post).and_raise Timeout::Error
      response, error = Client.new.post_notification({})
      expect(response).to be_nil
      expect(error).to eq(Client::RequestTimeout)
    end
  end

  describe Client, '#get_notifications' do
    include_context 'client specs'

    it 'gets all notifications for a user' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_producer(:username => 'heroku-postgres', :api_key => 'abc')
      fake_keikoku.register_user(:api_key => 'api-key', :account_email => 'harold@heroku.com')
      build_notification(:account_email => 'harold@heroku.com', :message => 'find me!',
                         :producer_api_key => 'abc', :producer_username => 'heroku-postgres').publish
      build_notification(:account_email => 'another@heroku.com', :producer_api_key => 'abc',
                         :producer_username => 'heroku-postgres').publish

      client = Client.new(:api_key => 'api-key')

      notifications, error = client.get_notifications

      expect(error).to be_nil
      expect(notifications).to have(1).item

      expect(notifications.first[:message]).to eq('find me!')
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:get).and_raise Timeout::Error
      response, error = Client.new.get_notifications
      expect(response).to be_nil
      expect(error).to eq(Client::RequestTimeout)
    end

    it 'handles authentication failures' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_user(:api_key => 'api-key', :account_email => 'harold@heroku.com')
      client = Client.new(:api_key => 'bad-api-key')

      response, error = client.get_notifications

      expect(response).to be_empty
      expect(error).to eq(Client::Unauthorized)
    end
  end

  describe Client, '#read_notification' do
    include_context 'client specs'

    it 'marks the notification as read' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)

      fake_keikoku.register_producer(:username => 'heroku-postgres', :api_key => 'abc')
      fake_keikoku.register_user(:api_key => 'api-key', :account_email => 'harold@heroku.com')
      client = Client.new(:api_key => 'api-key')
      notification = build_notification(:account_email     => 'harold@heroku.com',
                                        :producer_api_key  => 'abc',
                                        :producer_username => 'heroku-postgres')
      notification.publish or raise "Notification publish error"

      response, error = client.read_notification(notification.remote_id)
      expect(error).to be_nil

      expect(response[:status]).to eq('ok')
    end

    it 'handles authentication errors' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_user(:api_key => 'api-key', :account_email => 'harold@heroku.com')
      client = Client.new(:api_key => 'bad-api-key')
      response, error = client.read_notification(1)
      expect(response).to be_empty
      expect(error).to eq(Client::Unauthorized)
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:post).and_raise Timeout::Error
      response, error = Client.new.read_notification(1)
      expect(response).to be_nil
      expect(error).to eq(Client::RequestTimeout)
    end
  end
end
