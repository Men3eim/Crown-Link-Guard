class Admin::AllowlistedDomainsController < Admin::BaseController
  def index
    @allowlisted_domains = AllowlistedDomain.order(:domain)
    @allowlisted_domain = AllowlistedDomain.new(active: true)
  end

  def create
    @allowlisted_domain = AllowlistedDomain.new(domain_params.merge(created_by: current_user.email))
    if @allowlisted_domain.save
      audit!("allowlisted_domain_created", @allowlisted_domain)
      redirect_to admin_allowlisted_domains_path, notice: "Domain added to allowlist."
    else
      @allowlisted_domains = AllowlistedDomain.order(:domain)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    domain = AllowlistedDomain.find(params[:id])
    domain.update!(domain_params)
    audit!("allowlisted_domain_updated", domain)
    redirect_to admin_allowlisted_domains_path, notice: "Allowlist entry updated."
  end

  def destroy
    domain = AllowlistedDomain.find(params[:id])
    audit!("allowlisted_domain_removed", domain, domain: domain.domain)
    domain.destroy!
    redirect_to admin_allowlisted_domains_path, notice: "Allowlist entry removed."
  end

  private

  def domain_params
    params.require(:allowlisted_domain).permit(:domain, :allow_subdomains, :notes, :active)
  end
end
