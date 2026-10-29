# Today's consultation, the form at the bottom of the patient history. Saving
# creates it the first time and keeps the form open so the report can be sent.
class Patients::TodayConsultationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consultation

  def show
  end

  def update
    @consultation.update!(consultation_params)
    redirect_to patient_today_consultation_path(@patient), notice: "Saved", status: :see_other
  end

  private

  def set_consultation
    @patient = Patient.find(params[:patient_id])
    @consultation = @patient.today_consultation
  end

  def consultation_params
    params.expect(consultation: Consultation::NOTES)
  end
end
