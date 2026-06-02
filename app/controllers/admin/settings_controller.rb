class Admin::SettingsController < Admin::BaseController
  def index
    @settings = SecuritySetting.order(:key)
  end

  def update
    params.fetch(:settings, {}).each do |key, value|
      setting = SecuritySetting.find_or_initialize_by(key: key)
      setting.value = value
      setting.updated_by = current_user.email
      setting.save!
      audit!("setting_updated", setting, key: key)
    end

    redirect_to admin_settings_path, notice: "Settings updated."
  end
end
