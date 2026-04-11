import { Controller } from "@hotwired/stimulus"

// Wizard parent controller — scroll smoothly on step transition.
// Skip scroll on the very first connect (initial page load) to avoid
// surprising the user with an auto-scroll on navigation arrival.
export default class extends Controller {
  static values = { step: Number }

  connect() {
    if (this._initialized) {
      this.element.scrollIntoView({ behavior: "smooth", block: "start" })
    }
    this._initialized = true
  }
}
