import { Controller } from "@hotwired/stimulus"

// Rust Map editor : canvas SVG + dots cliquables.
// click-to-add, drag-to-move, clavier 1/2/3/4 change status, Delete supprime.
// Persiste en JSON dans un hidden input au submit du formulaire parent.
export default class extends Controller {
  static targets = ["canvas", "stateInput", "summary", "scoreOutput"]
  static values = { zones: Array }

  connect() {
    this.zones = this.hasZonesValue ? [...this.zonesValue] : []
    this.selectedId = null
    this.dragState = null
    this.render()
    this.persist()
  }

  onCanvasClick(event) {
    if (this.dragState?.moved) { this.dragState = null; return }
    if (event.target !== this.canvasTarget && !event.target.closest("[data-role='bg']")) return
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100
    const zone = {
      id: `z${Date.now()}${Math.floor(Math.random() * 999)}`,
      x: +x.toFixed(2),
      y: +y.toFixed(2),
      status: "surface",
      label: "",
      note: ""
    }
    this.zones.push(zone)
    this.selectedId = zone.id
    this.persist()
    this.render()
  }

  onDotMouseDown(event) {
    event.stopPropagation()
    const id = event.currentTarget.dataset.zoneId
    this.selectedId = id
    this.dragState = { id, moved: false }
    this.render()
  }

  onCanvasMouseMove(event) {
    if (!this.dragState) return
    this.dragState.moved = true
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = Math.max(0, Math.min(100, ((event.clientX - rect.left) / rect.width) * 100))
    const y = Math.max(0, Math.min(100, ((event.clientY - rect.top) / rect.height) * 100))
    const z = this.zones.find(zz => zz.id === this.dragState.id)
    if (z) {
      z.x = +x.toFixed(2)
      z.y = +y.toFixed(2)
      this.persist()
      this.render()
    }
  }

  onCanvasMouseUp() {
    if (this.dragState) {
      setTimeout(() => { this.dragState = null }, 50)
    }
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
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.status = status; this.persist(); this.render() }
  }

  updateLabel(event) {
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.label = event.target.value; this.persist() }
  }

  updateNote(event) {
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.note = event.target.value; this.persist() }
  }

  deleteSelected() {
    this.zones = this.zones.filter(z => z.id !== this.selectedId)
    this.selectedId = null
    this.persist()
    this.render()
  }

  selectZone(event) {
    event.stopPropagation()
    this.selectedId = event.currentTarget.dataset.zoneId
    this.render()
  }

  persist() {
    if (this.hasStateInputTarget) {
      this.stateInputTarget.value = JSON.stringify(this.zones)
    }
    if (this.hasScoreOutputTarget) {
      this.scoreOutputTarget.textContent = this.computeScore()
    }
  }

  computeScore() {
    const severity = { ok: 0, surface: 5, deep: 12, perforation: 25 }
    const penalty = this.zones.reduce((acc, z) => acc + (severity[z.status] || 0), 0)
    return Math.max(0, 100 - penalty)
  }

  render() {
    this.canvasTarget.querySelectorAll("[data-role='dot']").forEach(el => el.remove())
    this.zones.forEach(z => {
      const dot = document.createElement("button")
      dot.type = "button"
      dot.dataset.role = "dot"
      dot.className = `absolute w-3.5 h-3.5 -translate-x-1/2 -translate-y-1/2 rust-dot-${z.status}${z.id === this.selectedId ? " ring-2 ring-accent-red ring-offset-2 ring-offset-bg-primary" : ""}`
      dot.style.left = `${z.x}%`
      dot.style.top = `${z.y}%`
      dot.dataset.zoneId = z.id
      dot.dataset.action = "mousedown->rust-map-editor#onDotMouseDown click->rust-map-editor#selectZone"
      dot.setAttribute("aria-label", `Zone ${z.label || z.status}`)
      this.canvasTarget.appendChild(dot)
    })
    this.renderSummary()
  }

  renderSummary() {
    if (!this.hasSummaryTarget) return
    const selected = this.zones.find(z => z.id === this.selectedId)
    if (!selected) {
      this.summaryTarget.innerHTML = `<p class="font-body italic text-text-muted text-[14px]">Cliquez sur la silhouette pour ajouter une zone.</p>`
      return
    }
    this.summaryTarget.innerHTML = `
      <p class="label-small text-accent-red mb-4">Zone sélectionnée</p>
      <div class="space-y-4">
        <div>
          <label class="label-small block mb-2">Libellé</label>
          <input type="text" value="${escapeHtml(selected.label || "")}" class="input-vera" placeholder="Plancher arrière droit" data-action="input->rust-map-editor#updateLabel" />
        </div>
        <div>
          <label class="label-small block mb-2">Sévérité</label>
          <select class="input-vera" data-action="change->rust-map-editor#setStatusFromSelect">
            <option value="ok" ${selected.status === "ok" ? "selected" : ""}>Sain</option>
            <option value="surface" ${selected.status === "surface" ? "selected" : ""}>Oxydation surface</option>
            <option value="deep" ${selected.status === "deep" ? "selected" : ""}>Corrosion profonde</option>
            <option value="perforation" ${selected.status === "perforation" ? "selected" : ""}>Perforation</option>
          </select>
        </div>
        <div>
          <label class="label-small block mb-2">Note (optionnel)</label>
          <textarea class="input-vera" rows="3" placeholder="Contexte, traitement prévu…" data-action="input->rust-map-editor#updateNote">${escapeHtml(selected.note || "")}</textarea>
        </div>
        <button type="button" class="btn-vera-secondary" data-action="click->rust-map-editor#deleteSelected">Supprimer la zone</button>
      </div>
    `
  }
}

function escapeHtml(s) {
  return String(s)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
}
