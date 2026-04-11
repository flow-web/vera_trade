import { Controller } from "@hotwired/stimulus"

// Severity map — mirrors Ruby RustZone::SEVERITY. Kept deliberately in sync
// with app/models/rust_zone.rb. Single file, obvious diff, low drift risk.
export const RUST_ZONE_SEVERITY = Object.freeze({
  ok: 0,
  surface: 5,
  deep: 12,
  perforation: 25,
})

// Rust Map editor : canvas + dots cliquables.
// click-to-add, drag-to-move, clavier 1/2/3/4 change status, Delete supprime.
// Persiste en JSON dans un hidden input au submit du formulaire parent.
export default class extends Controller {
  static targets = ["canvas", "stateInput", "summary", "scoreOutput"]
  static values = { zones: Array }

  connect() {
    this.zones = this.hasZonesValue ? [...this.zonesValue] : []
    this.selectedId = null
    this.dragState = null
    this.dragResetTimer = null
    this.render()
    this.persist()
  }

  disconnect() {
    if (this.dragResetTimer) {
      clearTimeout(this.dragResetTimer)
      this.dragResetTimer = null
    }
    this.dragState = null
  }

  onCanvasClick(event) {
    if (this.dragState?.moved) { this.dragState = null; return }
    // Ne créer un dot que si le clic n'est pas sur un dot existant.
    if (event.target.dataset.role === "dot") return
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100
    const zone = {
      id: `z${Date.now()}${Math.floor(Math.random() * 999)}`,
      x: +x.toFixed(2),
      y: +y.toFixed(2),
      status: "surface",
      label: "",
      note: "",
    }
    this.zones.push(zone)
    this.selectedId = zone.id
    this.persist()
    this.renderDots()
    this.renderSummary()
  }

  onDotMouseDown(event) {
    event.stopPropagation()
    const id = event.currentTarget.dataset.zoneId
    this.selectedId = id
    this.dragState = { id, moved: false }
    this.renderDots()
    this.renderSummary()
  }

  onCanvasMouseMove(event) {
    if (!this.dragState) return
    this.dragState.moved = true
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = Math.max(0, Math.min(100, ((event.clientX - rect.left) / rect.width) * 100))
    const y = Math.max(0, Math.min(100, ((event.clientY - rect.top) / rect.height) * 100))
    const z = this.zones.find((zz) => zz.id === this.dragState.id)
    if (z) {
      z.x = +x.toFixed(2)
      z.y = +y.toFixed(2)
      this.persist()
      // Mise à jour directe du style du dot — évite le full re-render pour
      // préserver le focus des champs de la sidebar durant le drag.
      this.updateDotPosition(z)
    }
  }

  onCanvasMouseUp() {
    if (!this.dragState) return
    if (this.dragResetTimer) clearTimeout(this.dragResetTimer)
    this.dragResetTimer = setTimeout(() => {
      this.dragState = null
      this.dragResetTimer = null
    }, 50)
  }

  onKeyDown(event) {
    if (!this.selectedId) return
    const map = { "1": "ok", "2": "surface", "3": "deep", "4": "perforation" }
    if (map[event.key]) {
      this.setStatus(map[event.key])
    } else if (event.key === "Delete" || event.key === "Backspace") {
      this.deleteSelected()
    }
  }

  setStatusFromSelect(event) {
    this.setStatus(event.target.value)
  }

  setStatus(status) {
    const z = this.zones.find((zz) => zz.id === this.selectedId)
    if (!z) return
    z.status = status
    this.persist()
    this.updateDotClass(z)
    // Update du select sans détruire le <textarea> actif.
    if (this.hasSummaryTarget) {
      const select = this.summaryTarget.querySelector("select[data-action*='setStatusFromSelect']")
      if (select) select.value = status
    }
  }

  updateLabel(event) {
    const z = this.zones.find((zz) => zz.id === this.selectedId)
    if (z) { z.label = event.target.value; this.persist() }
  }

  updateNote(event) {
    const z = this.zones.find((zz) => zz.id === this.selectedId)
    if (z) { z.note = event.target.value; this.persist() }
  }

  deleteSelected() {
    this.zones = this.zones.filter((z) => z.id !== this.selectedId)
    this.selectedId = null
    this.persist()
    this.renderDots()
    this.renderSummary()
  }

  selectZone(event) {
    event.stopPropagation()
    this.selectedId = event.currentTarget.dataset.zoneId
    this.renderDots()
    this.renderSummary()
  }

  persist() {
    if (this.hasStateInputTarget) {
      this.stateInputTarget.value = JSON.stringify(this.zones)
    }
    if (this.hasScoreOutputTarget) {
      this.scoreOutputTarget.textContent = String(this.computeScore())
    }
  }

  computeScore() {
    const penalty = this.zones.reduce((acc, z) => acc + (RUST_ZONE_SEVERITY[z.status] || 0), 0)
    return Math.max(0, 100 - penalty)
  }

  // --- Rendering ---------------------------------------------------------

  render() {
    this.renderDots()
    this.renderSummary()
  }

  renderDots() {
    if (!this.hasCanvasTarget) return
    this.canvasTarget.querySelectorAll("[data-role='dot']").forEach((el) => el.remove())
    this.zones.forEach((z) => this.canvasTarget.appendChild(this.buildDot(z)))
  }

  buildDot(z) {
    const dot = document.createElement("button")
    dot.type = "button"
    dot.dataset.role = "dot"
    dot.dataset.zoneId = z.id
    dot.className = this.dotClassName(z)
    dot.style.left = `${z.x}%`
    dot.style.top = `${z.y}%`
    dot.dataset.action = "mousedown->rust-map-editor#onDotMouseDown click->rust-map-editor#selectZone"
    dot.setAttribute("aria-label", `Zone ${z.label || z.status}`)
    return dot
  }

  dotClassName(z) {
    const base = `absolute w-3.5 h-3.5 -translate-x-1/2 -translate-y-1/2 rust-dot-${z.status}`
    return z.id === this.selectedId
      ? `${base} ring-2 ring-accent-red ring-offset-2 ring-offset-bg-primary`
      : base
  }

  updateDotPosition(z) {
    if (!this.hasCanvasTarget) return
    const el = this.canvasTarget.querySelector(`[data-zone-id="${z.id}"]`)
    if (!el) return
    el.style.left = `${z.x}%`
    el.style.top = `${z.y}%`
  }

  updateDotClass(z) {
    if (!this.hasCanvasTarget) return
    const el = this.canvasTarget.querySelector(`[data-zone-id="${z.id}"]`)
    if (!el) return
    el.className = this.dotClassName(z)
  }

  // Construit la sidebar via document.createElement + textContent/value — aucune
  // donnée utilisateur n'est jamais parsée comme HTML.
  renderSummary() {
    if (!this.hasSummaryTarget) return
    const selected = this.zones.find((z) => z.id === this.selectedId)

    this.summaryTarget.replaceChildren()

    if (!selected) {
      const p = document.createElement("p")
      p.className = "font-body italic text-text-muted text-[14px]"
      p.textContent = "Cliquez sur la silhouette pour ajouter une zone."
      this.summaryTarget.appendChild(p)
      return
    }

    const header = document.createElement("p")
    header.className = "label-small text-accent-red mb-4"
    header.textContent = "Zone sélectionnée"
    this.summaryTarget.appendChild(header)

    const wrap = document.createElement("div")
    wrap.className = "space-y-4"
    wrap.appendChild(this.buildLabelField(selected))
    wrap.appendChild(this.buildSeveritySelect(selected))
    wrap.appendChild(this.buildNoteField(selected))
    wrap.appendChild(this.buildDeleteButton())
    this.summaryTarget.appendChild(wrap)
  }

  buildLabelField(selected) {
    const group = document.createElement("div")
    const label = document.createElement("label")
    label.className = "label-small block mb-2"
    label.textContent = "Libellé"
    const input = document.createElement("input")
    input.type = "text"
    input.value = selected.label || ""
    input.className = "input-vera"
    input.placeholder = "Plancher arrière droit"
    input.dataset.action = "input->rust-map-editor#updateLabel"
    group.appendChild(label)
    group.appendChild(input)
    return group
  }

  buildSeveritySelect(selected) {
    const group = document.createElement("div")
    const label = document.createElement("label")
    label.className = "label-small block mb-2"
    label.textContent = "Sévérité"
    const select = document.createElement("select")
    select.className = "input-vera"
    select.dataset.action = "change->rust-map-editor#setStatusFromSelect"
    const options = [
      ["ok", "Sain"],
      ["surface", "Oxydation surface"],
      ["deep", "Corrosion profonde"],
      ["perforation", "Perforation"],
    ]
    for (const [value, text] of options) {
      const opt = document.createElement("option")
      opt.value = value
      opt.textContent = text
      if (selected.status === value) opt.selected = true
      select.appendChild(opt)
    }
    group.appendChild(label)
    group.appendChild(select)
    return group
  }

  buildNoteField(selected) {
    const group = document.createElement("div")
    const label = document.createElement("label")
    label.className = "label-small block mb-2"
    label.textContent = "Note (optionnel)"
    const textarea = document.createElement("textarea")
    textarea.className = "input-vera"
    textarea.rows = 3
    textarea.placeholder = "Contexte, traitement prévu…"
    textarea.value = selected.note || ""
    textarea.dataset.action = "input->rust-map-editor#updateNote"
    group.appendChild(label)
    group.appendChild(textarea)
    return group
  }

  buildDeleteButton() {
    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "btn-vera-secondary"
    btn.textContent = "Supprimer la zone"
    btn.dataset.action = "click->rust-map-editor#deleteSelected"
    return btn
  }
}
