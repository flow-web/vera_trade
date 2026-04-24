import { Controller } from "@hotwired/stimulus"

// Minimal mobile nav toggle — slide-down panel
export default class extends Controller {
  static targets = ["panel", "openIcon", "closeIcon"]

  toggle() {
    const isOpen = !this.panelTarget.classList.contains("hidden")
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
