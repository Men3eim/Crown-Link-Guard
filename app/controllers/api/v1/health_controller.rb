class Api::V1::HealthController < Api::V1::BaseController
  skip_before_action :authenticate_extension_token, only: :show

  def show
    render json: { status: "ok", app: "Crown Link Guard", version: "1.0.0" }
  end
end
