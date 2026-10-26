class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action { sidemenu_active(:patients) }

  def index
    @patients = Patient.search(params[:term]).order(created_at: :desc).page(params[:page])
  end

  def show
    @patient = Patient.includes(:consultations).find(params[:id])
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to patient_path(@patient)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @patient = Patient.find(params[:id])

    respond_to(&:turbo_stream)
  end

  def update
    @patient = Patient.find(params[:id])
    @patient.assign_attributes(patient_params)

    @result = @patient.save

    respond_to(&:turbo_stream)
  end

  def cancel_edit
    @patient = Patient.find(params[:id])

    respond_to(&:turbo_stream)
  end

  private

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :birth_date, :phone, :address, :email, :dni)
  end
end
