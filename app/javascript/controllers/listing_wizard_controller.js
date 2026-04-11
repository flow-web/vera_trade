import { Controller } from "@hotwired/stimulus"

// Wizard parent controller — tracks current step value and scrolls smoothly
// when the turbo-frame is replaced.
export default class extends Controller {
  static values = { step: Number }

  connect() {
    if (typeof window !== "undefined") {
      this.element.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }

  stepValueChanged(newValue, oldValue) {
    if (typeof oldValue !== "undefined" && newValue !== oldValue) {
      console.debug(`[wizard] step ${oldValue} → ${newValue}`)
    }
  }
}
