import { Controller } from "@hotwired/stimulus"

// Timeline provenance dynamique — ajoute / supprime des rows via template.
// Focus management : après add, focus le premier champ de la nouvelle row.
// Après remove, focus la row suivante, précédente, ou le bouton "Ajouter".
export default class extends Controller {
  static targets = ["list", "template"]

  add() {
    const html = this.templateTarget.innerHTML
    this.listTarget.insertAdjacentHTML("beforeend", html)
    const added = this.listTarget.lastElementChild
    const firstInput = added?.querySelector("input, select, textarea")
    if (firstInput) firstInput.focus()
  }

  remove(event) {
    const row = event.currentTarget.closest("[data-provenance-row]")
    if (!row) return

    const next = row.nextElementSibling
    const prev = row.previousElementSibling
    row.remove()

    const target = next?.querySelector("input, select, textarea") ||
                   prev?.querySelector("input, select, textarea") ||
                   this.element.querySelector("[data-action*='provenance-timeline#add']")
    if (target) target.focus()
  }
}
