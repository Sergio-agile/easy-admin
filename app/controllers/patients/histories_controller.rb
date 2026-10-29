# All of a patient's past consultations on one page, newest at the bottom, with
# today's consultation as a form below them. Older pages load into lazy Turbo
# Frames as the user scrolls up.
class Patients::HistoriesController < ApplicationController
  PER_PAGE = 10

  before_action :authenticate_user!
  before_action { sidemenu_active(:patients) }

  def show
    @patient = Patient.find(params[:patient_id])
    @today = @patient.today_consultation
    @consultations = @patient.consultations.history.where.not(id: @today.id).page(params[:page]).per(PER_PAGE).without_count
  end
end
