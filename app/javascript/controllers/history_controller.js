import { Controller } from "@hotwired/stimulus"

// Chat-style patient history: starts at the bottom (newest consultations) and
// keeps the view still when older consultations load above it. "First" goes to
// the top and keeps it there until every older page has loaded.
export default class extends Controller {
  connect() {
    this.scrollToBottom()
    // Turbo scrolls to the top after rendering a visit; scroll back once it is done.
    document.addEventListener("turbo:load", this.scrollToBottom, { once: true })
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.scrollToBottom)
  }

  scrollToBottom = () => {
    window.scrollTo(0, document.documentElement.scrollHeight)
  }

  toStart() {
    this.goingToStart = true
    window.scrollTo(0, 0)
  }

  beforeFrameRender(event) {
    if (this.isPage(event)) this.fromBottom = document.documentElement.scrollHeight - window.scrollY
  }

  frameRender(event) {
    if (!this.isPage(event)) return

    if (this.goingToStart) {
      // The next older page's lazy frame is now at the top, in view, so it loads too.
      window.scrollTo(0, 0)
      this.goingToStart = event.target.querySelector("turbo-frame[loading=lazy]") !== null
    } else {
      window.scrollTo(0, document.documentElement.scrollHeight - this.fromBottom)
    }
  }

  isPage(event) {
    return event.target.id.startsWith("history_page_")
  }
}
