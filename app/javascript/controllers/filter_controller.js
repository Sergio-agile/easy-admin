import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["search"];
  static values = {
    url: String
  };

  connect() {
    this.url = window.location.href;
  }

  filter(event) {
    event.preventDefault();
    const term = this.searchTarget.value;
    get(`${this.url}`, {
      responseKind: "turbo-stream",
      query: { term: term }
    });
  }
}
