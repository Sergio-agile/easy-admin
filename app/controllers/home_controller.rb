class HomeController < ApplicationController

  before_action :authenticate_user!
  before_action { sidemenu_active(:home) }

  def index

  end

end
