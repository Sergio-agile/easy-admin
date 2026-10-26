require "rails_helper"

RSpec.describe PdfRenderer do
  def text_of(pdf)
    PDF::Reader.new(StringIO.new(pdf)).pages.map(&:text).join("\n")
  end

  it "prints HTML to a PDF" do
    pdf = described_class.render("<p>Hacer estiramientos</p>")

    expect(text_of(pdf)).to include("Hacer estiramientos")
  end

  it "does not run JavaScript" do
    pdf = described_class.render(%(<p id="notes">Notas</p><script>document.getElementById("notes").textContent = "JS ran"</script>))

    expect(text_of(pdf)).to include("Notas")
    expect(text_of(pdf)).not_to include("JS ran")
  end

  it "does not make network requests" do
    server = TCPServer.new("127.0.0.1", 0)
    url = "http://127.0.0.1:#{server.addr[1]}/tracker.png"

    described_class.render(%(<img src="#{url}"><link rel="stylesheet" href="#{url}">))

    expect(server.accept_nonblock(exception: false)).to eq(:wait_readable)
  ensure
    server&.close
  end
end
