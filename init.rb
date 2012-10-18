$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'keikokuc', 'lib')
require './vendor/keikokuc/lib/keikokuc'
require 'heroku/command/base'
require 'heroku/command/notifications'
