class ApplicationController < ActionController::Base
  include Pagy::Backend

  def sidemenu_active(key)
    @sidemenu_active = key
  end
end
