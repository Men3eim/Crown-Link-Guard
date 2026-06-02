class Api::V1::ReportsController < Api::V1::BaseController
  def create
    metadata = report_params.to_h.symbolize_keys
    analysis = UrlRiskAnalyzer.call(metadata[:url], metadata)

    AgentReport.create!(
      original_url: analysis[:original_url],
      normalized_url: analysis[:normalized_url],
      domain: analysis[:domain],
      ticket_url: metadata[:ticket_url],
      ticket_id: metadata[:ticket_id],
      agent_email: metadata[:agent_email],
      agent_name: metadata[:agent_name],
      agent_note: metadata[:agent_note],
      risk_score: analysis[:risk_score],
      risk_level: analysis[:risk_level],
      reasons: analysis[:reasons],
      status: "pending"
    )

    render json: { success: true, message: "Reported successfully. Please do not open the link until it is reviewed." }
  end

  private

  def report_params
    params.permit(:url, :ticket_url, :ticket_id, :agent_email, :agent_name, :agent_note)
  end
end
