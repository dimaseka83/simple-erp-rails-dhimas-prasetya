class LocalesController < ApplicationController
  allow_unauthenticated_access

  def update
    result = ::LocalesManager.switch(locale: params[:locale])
    cookies.permanent[:locale] = result.object if result.success?
    redirect_back fallback_location: root_path
  end
end
