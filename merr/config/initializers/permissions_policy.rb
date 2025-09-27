# frozen_string_literal: true

# https://api.rubyonrails.org/classes/ActionController/PermissionsPolicy.html

# HTTP Permissions Policy is a web standard for defining a
# mechanism to allow and deny the use of browser permissions
# in its own context, and in content within any <iframe> elements
# in the document.

# Can be overridden at the controller level:
# class PagesController < ApplicationController
#   permissions_policy do |p|
#     p.geolocation "https://example.com"
#   end
# end

Rails.application.config.permissions_policy do |f|
  f.camera      :none
  f.gyroscope   :none
  f.microphone  :none
  f.usb         :none
  f.fullscreen  :none
  f.payment     :none
end
