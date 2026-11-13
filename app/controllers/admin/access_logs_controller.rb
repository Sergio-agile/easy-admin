# Who saw or changed which patient, newest first, with filters.
class Admin::AccessLogsController < Admin::BaseController
  # `event` because `action` is taken by Rails (the controller action name).
  FILTERS = %i[user_id patient event from to].freeze

  def index
    @filters = params.permit(*FILTERS).to_h.symbolize_keys
    @access_logs = AccessLog.filter(**@filters.except(:event), action: @filters[:event]).includes(:user, :patient, :consultation).recent.page(params[:page])
    @users = User.order(:first_name, :last_name)
    log_access(:access_log_viewed)
  end
end
