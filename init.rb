$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'keikokuc', 'lib')
require 'keikokuc'
require File.expand_path('lib/heroku/command-ext', File.dirname(__FILE__))
require 'heroku/command/base'
require 'heroku/command/notifications'
require 'heroku/notification_count'
