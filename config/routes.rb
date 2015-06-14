DiasporaFederation::Engine.routes.draw do
  controller :receive do
    post "receive/public"      => :public,  :as => "receive_public"
    post "receive/users/:guid" => :private, :as => "receive_private"
  end

  controller :webfinger do
    get ".well-known/host-meta" => :host_meta,        :as => "host_meta"
    get "webfinger"             => :legacy_webfinger, :as => "legacy_webfinger"
  end
end
