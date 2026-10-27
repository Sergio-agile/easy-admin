class ConsultationsController < ApplicationController
  before_action :authenticate_user!
  before_action { sidemenu_active(:consultations) }

  def index
    @consultations = Consultation.includes(:patient).search(params[:term]).order(created_at: :desc).page(params[:page])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @consultation = Consultation.new
  end

  def create
    @consultation = Consultation.new(consultation_params)
    @patient = Patient.find(params[:patient_id])
    @consultation.patient = @patient
    if @consultation.save
      redirect_to patient_path(@patient)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @consultation = Consultation.includes(
      :patient,
      :rich_text_notes_before,
      :rich_text_notes_after,
      :rich_text_notes_to_send
    ).find(params[:id])
  end

  def update
    @consultation = Consultation.find(params[:id])
    @consultation.assign_attributes(consultation_params)

    if @consultation.save
      redirect_to patient_path(@consultation.patient)
    else
      render :new, status: :unprocessable_content
    end
  end

  def download
    @report = ConsultationReport.new(Consultation.includes(:patient, :rich_text_notes_to_send).find(params[:id]))

    respond_to do |format|
      format.html { render layout: "report" }
      format.pdf { send_data @report.to_pdf, filename: @report.filename, type: :pdf, disposition: :attachment }
    end
  end

  private

  def consultation_params
    params.require(:consultation).permit(:notes_after, :notes_before, :notes_to_send)
  end
end
