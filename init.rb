$:.unshift File.expand_path(File.join('vendor', 'keikokuc', 'lib'), File.dirname(__FILE__))
puts $:
require 'keikokuc'
require 'heroku/command/base'
require 'heroku/command/notifications'
