class Api::V1::BaseController < ActionController::API
  before_action :set_cors_headers
  before_action :authenticate_extension_token

  rescue_from StandardError, with: :render_internal_error

  private

  def set_cors_headers
    response.set_header("Access-Control-Allow-Origin", request.headers["Origin"].presence || "*")
    response.set_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
    response.set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  end

  def authenticate_extension_token
    token = request.authorization.to_s.delete_prefix("Bearer ").strip
    valid_tokens = [
      ENV["CROWN_LINK_GUARD_API_TOKEN"],
      security_setting_token
    ].compact.reject(&:blank?)

    return if valid_tokens.any? && valid_tokens.include?(token)

    render json: { error: "Unauthorized extension API request" }, status: :unauthorized
  end

  def security_setting_token
    SecuritySetting.find_by(key: "api_token")&.value
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def render_internal_error(error)
    Rails.logger.error("#{error.class}: #{error.message}")
    render json: { error: "Crown Link Guard could not process this request." }, status: :internal_server_error
  end
end
