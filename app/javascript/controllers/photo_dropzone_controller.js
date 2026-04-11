import { Controller } from "@hotwired/stimulus"

// Preview dropzone. Files themselves upload via the multipart form submit
// on the hidden file input — Stimulus only drives the UX (preview, drag over).
export default class extends Controller {
  static targets = ["input", "list"]

  connect() { this.files = [] }

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
    reader.onload = (e) => {
      const li = document.createElement("li")
      li.className = "relative border border-line aspect-[4/3] overflow-hidden"
      li.innerHTML = `
        <img src="${e.target.result}" class="w-full h-full object-cover" alt="${file.name}" />
        <span class="absolute bottom-0 left-0 right-0 px-2 py-1 font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted bg-bg-primary/80 truncate">${file.name}</span>
      `
      this.listTarget.appendChild(li)
    }
    reader.readAsDataURL(file)
  }
}
