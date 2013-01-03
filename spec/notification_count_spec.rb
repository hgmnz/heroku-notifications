require 'spec_helper'

describe Heroku::NotificationCount do
  it 'fetches notification counts' do
    list = Keikokuc::NotificationList.new({:api_key => 'fake'})
    mock(list).fetch
    mock(list).count { 2 }
    mock(Keikokuc::NotificationList).new.with_any_args { list }
    counter = Heroku::NotificationCount.new
    counter.fetch

    loop { break if counter.done? }

    counter.should have_notifications
  end
end
