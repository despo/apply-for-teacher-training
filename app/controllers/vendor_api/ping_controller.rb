module VendorAPI
  class PingController < VendorAPIController
    def ping
      raise
      render json: { data: 'pong' }
    end
  end
end
