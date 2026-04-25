import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    this._close = this.close.bind(this)
    this._escape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this._close)
    document.addEventListener("keydown", this._escape)
  }

  disconnect() {
    document.removeEventListener("click", this._close)
    document.removeEventListener("keydown", this._escape)
  }
}
