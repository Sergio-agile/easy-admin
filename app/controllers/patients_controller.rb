class PatientsController < ApplicationController

  def index
    if params['term'].present?
      @patients = Patient.where("first_name ILIKE ?", "#{params['term']}%").order(created_at: :desc).page params[:page]
    else
      @patients = Patient.all.order(created_at: :desc).page params[:page]
    end
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @patient = Patient.find(params[:id])
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to patient_path(@patient)
    else
      render :new, status: :unprocessable_entity
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
