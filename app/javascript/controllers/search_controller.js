import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]
  
  connect() {
    this.timeout = null
  }
  
  search() {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value
      if (query.length >= 2) {
        window.location.href = `/listings?query=${encodeURIComponent(query)}`
      }
    }, 500)
  }

  showSuggestions() {
    this.suggestionsTarget.classList.remove('hidden')
  }

  hideSuggestions() {
    setTimeout(() => {
      this.suggestionsTarget.classList.add('hidden')
    }, 200)
  }

  useSuggestion(event) {
    const suggestion = event.target.textContent.trim()
    this.inputTarget.value = suggestion
    this.search()
  }
} 