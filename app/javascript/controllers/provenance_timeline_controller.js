import { Controller } from "@hotwired/stimulus"

// Timeline provenance dynamique — ajoute / supprime des rows via template.
export default class extends Controller {
  static targets = ["list", "template"]

  add() {
    const html = this.templateTarget.innerHTML
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.currentTarget.closest("[data-provenance-row]").remove()
  }
}
