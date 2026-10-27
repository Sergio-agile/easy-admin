# The report of a consultation that is sent to the patient: the notes to send,
# shown as an HTML preview and downloaded as a PDF.
class ConsultationReport
  LOGO = Rails.root.join("app/assets/images/logo-infinito.png")

  attr_reader :consultation

  delegate :patient, :date, :notes_to_send, to: :consultation

  def initialize(consultation)
    @consultation = consultation
  end

  def patient_name
    "#{patient.first_name} #{patient.last_name}"
  end

  def filename
    I18n.t("consultation_report.filename", patient: patient_name.parameterize, date: date.iso8601)
  end

  # The PDF can't fetch assets, so the logo travels inside the HTML.
  def logo_data_uri
    "data:image/png;base64,#{Base64.strict_encode64(LOGO.binread)}"
  end

  def to_html
    ApplicationController.render(template: "consultation_reports/show", layout: "report", assigns: { report: self })
  end

  def to_pdf
    PdfRenderer.render(to_html)
  end
end
