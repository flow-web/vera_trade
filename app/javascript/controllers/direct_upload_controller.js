import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="direct-upload"
export default class extends Controller {
  static targets = ["input", "progress", "preview"]

  connect() {
    console.log("Direct upload controller connected")
    this.bindEvents()
  }

  bindEvents() {
    if (!this.hasInputTarget) return
    
    this.inputTarget.addEventListener("direct-upload:initialize", event => {
      console.log("Upload initialized", event)
    })

    this.inputTarget.addEventListener("direct-upload:start", event => {
      console.log("Upload started", event)
    })

    this.inputTarget.addEventListener("direct-upload:progress", event => {
      const { id, progress } = event.detail
      console.log(`Upload progress: ${progress}%`)
      
      if (this.hasProgressTarget) {
        this.progressTarget.value = progress
        this.progressTarget.classList.remove("hidden")
      }
    })

    this.inputTarget.addEventListener("direct-upload:error", event => {
      event.preventDefault()
      const { id, error } = event.detail
      console.error(`Error during upload: ${error}`)
      
      // Afficher un message d'erreur à l'utilisateur
      alert(`Erreur lors du téléchargement : ${error}`)
    })

    this.inputTarget.addEventListener("direct-upload:end", event => {
      console.log("Upload ended", event)
      
      if (this.hasProgressTarget) {
        this.progressTarget.classList.add("hidden")
      }
    })
  }
} 