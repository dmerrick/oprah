#!/usr/bin/env ruby

require 'hello'

Sinatra::Application.default_options.merge!(
  :run => false
)

run Sinatra::Application

# vim: ft=ruby
