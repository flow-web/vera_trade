import { Controller } from "@hotwired/stimulus"

// Preview dropzone. Files themselves upload via the multipart form submit
// on the hidden file input — Stimulus only drives the UX (preview, drag over).
// Max 10 files, images only, server enforces content_type + size via
// Active Storage validators on the Listing model.
export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    this.files = []
    this.pendingReaders = new Set()
  }

  disconnect() {
    // Abort any in-flight FileReader so the onload callback doesn't run on a
    // detached DOM after a Turbo frame replacement.
    for (const reader of this.pendingReaders) {
      try { reader.abort() } catch (_) { /* noop */ }
    }
    this.pendingReaders.clear()
    this.files = []
  }

  browse(event) {
    if (event.target.tagName === "INPUT") return
    this.inputTarget.click()
  }

  onDrop(event) {
    event.preventDefault()
    this.element.classList.remove("border-accent-red")
    this.addFiles(event.dataTransfer.files)
  }

  onDragOver(event) {
    event.preventDefault()
    this.element.classList.add("border-accent-red")
  }

  onDragLeave() { this.element.classList.remove("border-accent-red") }

  onChange(event) { this.addFiles(event.target.files) }

  addFiles(fileList) {
    for (const file of Array.from(fileList)) {
      if (this.files.length >= 10) break
      if (!file.type.startsWith("image/")) continue
      this.files.push(file)
      this.renderThumb(file)
    }
  }

  renderThumb(file) {
    const reader = new FileReader()
    this.pendingReaders.add(reader)

    reader.onload = (e) => {
      this.pendingReaders.delete(reader)
      if (!this.hasListTarget) return // disconnected mid-read

      // Build DOM via element API so file.name is never parsed as HTML.
      const li = document.createElement("li")
      li.className = "relative border border-line aspect-[4/3] overflow-hidden"

      const img = document.createElement("img")
      img.src = e.target.result                 // safe : data: URL from FileReader
      img.className = "w-full h-full object-cover"
      img.setAttribute("alt", file.name)        // setAttribute treats as text
      img.setAttribute("loading", "lazy")
      li.appendChild(img)

      const caption = document.createElement("span")
      caption.className = "absolute bottom-0 left-0 right-0 px-2 py-1 font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted bg-bg-primary/80 truncate"
      caption.textContent = file.name            // textContent = no HTML parse
      li.appendChild(caption)

      this.listTarget.appendChild(li)
    }

    reader.onerror = () => { this.pendingReaders.delete(reader) }
    reader.onabort = () => { this.pendingReaders.delete(reader) }

    reader.readAsDataURL(file)
  }
}
