#!/usr/bin/env ruby
# Encoding: utf-8

require 'httparty'
require 'json'

host = ENV.fetch("JENKINS_HOST")
job = ARGV.fetch(0, nil)
fail 'No job name provided' unless job

url = "#{host}/job/#{job}/lastSuccessfulBuild/api/json"

response = HTTParty.get(url)
parsed_response = JSON.parse(response.body, symbolize_names: true)

if parsed_response.fetch(:result) == "SUCCESS"
  puts "💚"
else
  puts "💔"
end
