import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "form"]
  
  connect() {
    this.timeout = null
    console.log("Search controller connected")
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

  filter(event) {
    console.log("Filter method called", event)
    event.preventDefault()
    
    try {
      // Get the map container element
      const mapElement = document.querySelector('[data-controller*="map"]')
      console.log("Map element found:", mapElement)
      
      if (mapElement) {
        // Dispatch a custom event with the form data
        const formData = new FormData(event.target)
        const filterData = {}
        
        // Convert FormData to a regular object
        for (let [key, value] of formData.entries()) {
          filterData[key] = value
        }
        
        console.log("Filter data:", filterData)
        
        // Dispatch the event to the map element
        mapElement.dispatchEvent(new CustomEvent('search:filter', {
          detail: { 
            filters: filterData,
            form: event.target
          },
          bubbles: true
        }))
        
      } else {
        console.error("Map element not found, submitting form normally")
        event.target.submit()
      }
    } catch (error) {
      console.error("Error in filter method:", error)
      event.target.submit()
    }
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