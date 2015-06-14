module DiasporaFederation
  ##
  # diaspora* federation rails engine
  class Engine < ::Rails::Engine
    isolate_namespace DiasporaFederation

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
