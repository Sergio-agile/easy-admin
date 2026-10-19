# frozen_string_literal: true

# Active Storage routes (Trix direct uploads, attachment downloads) are public by
# default. Attachments belong to consultations, so require a signed in user.
Rails.application.config.to_prepare do
  ActiveStorage::BaseController.class_eval do
    before_action :require_signed_in_user

    private

    def require_signed_in_user
      head :unauthorized unless session[:user_id] && User.exists?(id: session[:user_id])
    end
  end
end
