class Api::V1::ActionsController < Api::V1::BaseController
  def create
    scan = UrlScan.find(params[:scan_id])
    action = params[:action_taken].to_s

    unless UrlScan::ACTIONS.include?(action)
      return render json: { error: "Unsupported action" }, status: :unprocessable_entity
    end

    scan.update!(action_taken: action, agent_email: params[:agent_email].presence || scan.agent_email)
    render json: { success: true }
  end
end
