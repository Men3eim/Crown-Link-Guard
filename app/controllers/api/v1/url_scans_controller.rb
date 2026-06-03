class Api::V1::UrlScansController < Api::V1::BaseController
  def create
    metadata = scan_params.to_h.symbolize_keys
    metadata[:user_agent] = request.user_agent
    analysis = UrlRiskAnalyzer.call(metadata[:url], metadata)
    scan = ScanLogger.call(analysis, metadata)

    render json: analysis.merge(scan_id: scan.id)
  end

  private

  def scan_params
    params.permit(:url, :ticket_url, :page_url, :page_domain, :ticket_id, :agent_email, :agent_name, :device_name, :source, :hidden_link, :link_text)
  end
end
