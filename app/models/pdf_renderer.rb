# Prints self-contained HTML (inline styles, data: images) to an A4 PDF with
# headless Chromium.
#
# Each PDF starts and quits its own browser, so no memory stays in use between
# renders (production has 1 GB). JavaScript is off and every network request
# is blocked: the HTML holds user-written notes, and Chromium must not fetch
# anything for them. That is also why running without the Chromium sandbox,
# which Docker doesn't support, is acceptable here.
class PdfRenderer
  # --single-process would use less memory (~85 MB instead of ~190 MB), but on
  # the 1 vCPU droplet it was 2-3x slower and opening the page timed out.
  BROWSER_OPTIONS = {
    "no-sandbox" => nil,
    "disable-gpu" => nil,
    "disable-dev-shm-usage" => nil
  }.freeze

  # Ferrum's defaults (10 s to start, 5 s per internal call) are too tight
  # for the droplet under memory pressure; a render normally takes ~2 s there.
  TIMEOUTS = { timeout: 30, process_timeout: 30, protocol_timeout: 30 }.freeze

  def self.render(html)
    browser = Ferrum::Browser.new(browser_options: BROWSER_OPTIONS, **TIMEOUTS)
    page = browser.create_page
    page.disable_javascript
    page.network.blocklist = /.*/
    page.content = html
    page.pdf(encoding: :binary, format: :A4, print_background: true)
  ensure
    browser&.quit
  end
end
