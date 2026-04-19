import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "image", "counter"]

  connect() {
    this.photos = Array.from(this.element.querySelectorAll("[data-photo-url]"))
    this.currentIndex = 0
  }

  open(event) {
    const el = event.currentTarget
    this.currentIndex = this.photos.indexOf(el)
    this.show(this.currentIndex)
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  next() {
    this.show((this.currentIndex + 1) % this.photos.length)
  }

  prev() {
    this.show((this.currentIndex - 1 + this.photos.length) % this.photos.length)
  }

  onKeydown(event) {
    if (event.key === "ArrowRight") this.next()
    else if (event.key === "ArrowLeft") this.prev()
    else if (event.key === "Escape") this.close()
  }

  onBackdropClick(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  show(index) {
    this.currentIndex = index
    const url = this.photos[index]?.dataset.photoUrl
    if (url) this.imageTarget.src = url
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${index + 1} / ${this.photos.length}`
    }
  }
}
