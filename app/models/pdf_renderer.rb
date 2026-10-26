# Prints self-contained HTML (inline styles, data: images) to an A4 PDF with
# headless Chromium.
#
# Each PDF starts and quits its own browser, so no memory stays in use between
# renders (production has 1 GB). JavaScript is off and every network request
# is blocked: the HTML holds user-written notes, and Chromium must not fetch
# anything for them. That is also why running without the Chromium sandbox,
# which Docker doesn't support, is acceptable here.
class PdfRenderer
  BROWSER_OPTIONS = {
    "no-sandbox" => nil,
    # One process instead of a browser + renderer tree: ~85 MB instead of ~190 MB, and 4x faster
    "single-process" => nil,
    "no-zygote" => nil,
    "disable-gpu" => nil,
    "disable-dev-shm-usage" => nil
  }.freeze

  def self.render(html)
    browser = Ferrum::Browser.new(browser_options: BROWSER_OPTIONS, timeout: 15)
    page = browser.create_page
    page.disable_javascript
    page.network.blocklist = /.*/
    page.content = html
    page.pdf(encoding: :binary, format: :A4, print_background: true)
  ensure
    browser&.quit
  end
end
