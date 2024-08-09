class PatientsController < ApplicationController

  def index
    @patients = Patient.all.order(created_at: :desc)
  end

end
