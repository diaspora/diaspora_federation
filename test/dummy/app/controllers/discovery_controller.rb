class DiscoveryController < ApplicationController
  def discovery
    discovery = DiasporaFederation::Discovery::Discovery.new(params[:q])

    render json: discovery.fetch
  end
end
