module DiasporaFederation
  module Federation
    # Federation logic to send messages to other pods
    module Sender
      # Send a public message to all urls
      #
      # @param [String] sender_id sender diaspora-ID
      # @param [String] guid guid of the object to send (can be nil if the object has no guid)
      # @param [Array<String>] urls receive-urls from pods
      # @param [String] xml salmon-xml
      # @return [Array<String>] url to retry
      def self.public(sender_id, guid, urls, xml)
        hydra = HydraWrapper.new(sender_id, guid)
        urls.each {|url| hydra.insert_job(url, xml) }
        hydra.send
      end

      # Send a private message to receive-urls
      #
      # @param [String] sender_id sender diaspora-ID
      # @param [String] guid guid of the object to send (can be nil if the object has no guid)
      # @param [Hash] targets Hash with receive-urls (key) of peoples with encrypted salmon-xml for them (value)
      # @return [Hash] targets to retry
      def self.private(sender_id, guid, targets)
        hydra = HydraWrapper.new(sender_id, guid)
        targets.each {|url, xml| hydra.insert_job(url, xml) }
        Hash[hydra.send.map {|url| [url, targets[url]] }]
      end
    end
  end
end

require "diaspora_federation/federation/sender/hydra_wrapper"
