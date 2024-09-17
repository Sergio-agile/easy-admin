class HomeController < ApplicationController

  before_action { sidemenu_active(:home) }

  def index
  end

end
