#!/usr/bin/env ruby

Sinatra::Application.default_options.merge!(
  :run => false
)

require 'hello'
run Sinatra::Application

# vim: ft=ruby
