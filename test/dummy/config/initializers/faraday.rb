# Use net_http in test, that's better supported by webmock
unless Rails.env.test?
  require "typhoeus/adapters/faraday"
  Faraday.default_adapter = :typhoeus
end
