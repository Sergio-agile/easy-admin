class ConsultationsController < ApplicationController

  include ::PdfRendererConcern

  before_action :authenticate_user!
  before_action { sidemenu_active(:consultations) }

  def index
    consultations

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
      render :new, status: :unprocessable_entity
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
      render :new, status: :unprocessable_entity
    end
  end

  def download
    @consultation = Consultation.find(params[:id])
    notes_to_send = render_to_string(template: "consultations/download", layout: "pdf", formats: [:html])

    respond_to do |format|
      format.html { render html: notes_to_send }
      format.pdf { render_pdf notes_to_send, filename: "report.pdf", layout: 'pdf' }
      # format.pdf { render_pdf notes_to_send, filename: t(".filename", id: @consultation.id) }
    end
  end

  private

  def consultation_params
    params.require(:consultation).permit(:notes_after, :notes_before, :notes_to_send)
  end

  def consultations
    @pagy, @consultations = pagy(filtered_consultations.order(created_at: :desc))
  end

  def filtered_consultations
    if params['term'].present?
      term = "%#{params['term']}%"
      Consultation.joins(:patient).where("patients.first_name ILIKE ? OR patients.last_name ILIKE ?", term, term)
    else
      Consultation.all
    end
  end


end
