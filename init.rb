$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'keikokuc', 'lib')
require 'heroku/command/base'
require 'heroku/command/notifications'
