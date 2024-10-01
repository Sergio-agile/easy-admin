module PdfRendererConcern

  extend ActiveSupport::Concern

  included do

    def render_pdf(html, filename:, layout: "pdf")
      pdf = WickedPdf.new.pdf_from_string(html, layout: layout)
      send_data pdf, filename: filename, type: 'application/pdf', disposition: 'attachment'
    end

  end

end
