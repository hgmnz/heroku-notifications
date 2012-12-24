$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'keikokuc', 'lib')
require 'keikokuc'
require 'heroku/command/base'
require 'heroku/command/notifications'
require 'heroku/notification_count'
