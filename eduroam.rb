# This is copied, verbatim, from Ruby 1.8.7's ping.rb.
require 'timeout'
require "socket"

module Ping
  def pingecho(host, timeout=5, service="echo")
    begin
      timeout(timeout) do
        s = TCPSocket.new(host, service)
        s.close
      end
    rescue Errno::ECONNREFUSED
      return true
    rescue Timeout::Error, StandardError
      return false
    end
    return true
  end
  module_function :pingecho
end

# The initial values for these don't matter.
oldusername = "test"
oldpassword = "test"
# The initial values for these must match what's already in the eduroam profile.
username = "conf003"
password = "DxY6WEO?"

File.open("eduroam_conf.csv").each do |record|
  arr = record.split("\t")
  oldusername = username
  oldpassword = password
  username = arr[0]
  password = arr[1]
  text = File.read("/etc/NetworkManager/system-connections/eduroam")
  text = text.gsub(/#{Regexp.escape(oldusername)}/, username)
  text = text.gsub(/password=#{Regexp.escape(oldpassword)}/, "password=#{password}")
  File.open("/etc/NetworkManager/system-connections/eduroam", "w") do |file|
    file.puts text
  end
  truncate_output = `service network-manager restart`
  i = 0
  while i < 30
    sleep 1
    if Ping.pingecho('www.google.com', 1, 80)
      break
    end
    i += 1
  end
  pingtest =  Ping.pingecho('www.google.com', 1, 80)
  puts "Username: #{username} Password: #{password} Valid: #{pingtest}"
end


