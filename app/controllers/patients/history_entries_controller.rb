# One past consultation inside the patient history, shown or edited in place in
# its Turbo Frame.
class Patients::HistoryEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_patient
  before_action :set_consultation

  def show
  end

  def edit
  end

  def update
    @consultation.update!(consultation_params)
    redirect_to patient_history_entry_path(@patient, @consultation), status: :see_other
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def set_consultation
    @consultation = @patient.consultations.with_all_rich_text.find(params[:id])
  end

  def consultation_params
    params.expect(consultation: Consultation::NOTES)
  end
end
