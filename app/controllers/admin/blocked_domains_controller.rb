class Admin::BlockedDomainsController < Admin::BaseController
  def index
    @blocked_domains = BlockedDomain.order(:domain)
    @blocked_domain = BlockedDomain.new(active: true, severity: "high")
  end

  def create
    @blocked_domain = BlockedDomain.new(domain_params.merge(created_by: current_user.email))
    if @blocked_domain.save
      audit!("blocked_domain_created", @blocked_domain)
      redirect_to admin_blocked_domains_path, notice: "Domain added to blocklist."
    else
      @blocked_domains = BlockedDomain.order(:domain)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    domain = BlockedDomain.find(params[:id])
    domain.update!(domain_params)
    audit!("blocked_domain_updated", domain)
    redirect_to admin_blocked_domains_path, notice: "Blocklist entry updated."
  end

  def destroy
    domain = BlockedDomain.find(params[:id])
    audit!("blocked_domain_removed", domain, domain: domain.domain)
    domain.destroy!
    redirect_to admin_blocked_domains_path, notice: "Blocklist entry removed."
  end

  private

  def domain_params
    params.require(:blocked_domain).permit(:domain, :severity, :reason, :active)
  end
end
