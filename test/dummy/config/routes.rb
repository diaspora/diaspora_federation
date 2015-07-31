Rails.application.routes.draw do
  mount DiasporaFederation::Engine => "/"

  get "discovery" => "discovery#discovery"
end
