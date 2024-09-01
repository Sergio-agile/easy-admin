class PatientsController < ApplicationController

  def index
    if params['term'].present?
      @patients = Patient.where("first_name ILIKE ?", "#{params['term']}%").order(created_at: :desc).page params[:page]
    else
      @patients = Patient.all.order(created_at: :desc).page params[:page]
    end
    respond_to do |format|
      format.html
      format.turbo_stream do
      end
    end
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)
    if @patient.save
      redirect_to patients_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :birthdate, :phone, :address, :email, :dni)
  end

end
