DiasporaFederation::Engine.routes.draw do
  controller :receive do
    post "receive/public"      => :public,  :as => "receive_public"
    post "receive/users/:guid" => :private, :as => "receive_private"
  end

  controller :fetch do
    get "fetch/:type/:guid" => :fetch, :as => "fetch"
  end

  controller :webfinger do
    get ".well-known/host-meta" => :host_meta,        :as => "host_meta"
    get "webfinger"             => :legacy_webfinger, :as => "legacy_webfinger"
  end

  controller :h_card do
    get "hcard/users/:guid" => :hcard, :as => "hcard"
  end
end
