DiasporaFederation::Engine.routes.draw do
  controller :receive do
    post "receive/public"      => :public,  :as => "receive_public"
    post "receive/users/:guid" => :private, :as => "receive_private"
  end
end
