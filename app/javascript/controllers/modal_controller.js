import { Controller } from "@hotwired/stimulus"

// PR3 feat/buyer-contact — generic modal controller.
//
// Wraps a Turbo Frame-loaded modal overlay. Handles three close vectors:
//   1. Explicit close button (data-action="modal#close")
//   2. Backdrop click outside the content panel (data-action="click->modal#closeOnBackdrop")
//   3. Escape key (data-action="keydown@window->modal#closeOnEscape")
//
// Closing clears the parent turbo-frame's innerHTML so the modal element
// is fully removed from the DOM — subsequent clicks on the trigger link
// will re-fetch the fresh server-rendered form.
export default class extends Controller {
  static targets = ["content"]

  close() {
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.innerHTML = ""
    } else {
      this.element.remove()
    }
  }

  closeOnBackdrop(event) {
    if (!this.hasContentTarget) return
    if (!this.contentTarget.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
