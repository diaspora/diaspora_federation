class DiscoveryController < ApplicationController
  def discovery
    discovery = DiasporaFederation::Discovery::Discovery.new(params[:q])

    render json: discovery.fetch_and_save
  end
end
