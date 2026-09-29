class SettingsController < ApplicationController
  def edit
    @setting = Setting.current
    @settings_presenter = SettingsPresenter.new(view_context, setting: @setting)
  end

  def update
    result = ::SettingsManager.update(**setting_params)
    if result.success?
      redirect_to edit_settings_path, notice: t(".notice")
    else
      @setting = result.object
      @settings_presenter = SettingsPresenter.new(view_context, setting: @setting)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def setting_params
      params.expect(setting: [ :currency ]).to_h.symbolize_keys
    end
end
