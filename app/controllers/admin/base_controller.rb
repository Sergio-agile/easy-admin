# Pages only admins can open: today the osteopath (data controller) and the developer (processor).
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action { sidemenu_active(:admin) }
end
