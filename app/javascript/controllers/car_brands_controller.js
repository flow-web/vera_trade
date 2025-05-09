import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]
  static values = {
    url: String
  }

  connect() {
    this.inputTarget.addEventListener("input", this.debounce(this.handleInput.bind(this), 300))
    this.inputTarget.addEventListener("blur", this.handleBlur.bind(this))
    this.inputTarget.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this.handleInput)
    this.inputTarget.removeEventListener("blur", this.handleBlur)
    this.inputTarget.removeEventListener("keydown", this.handleKeydown)
  }

  async handleInput(event) {
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.hideSuggestions()
      return
    }

    try {
      const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`)
      const brands = await response.json()
      
      if (brands.length > 0) {
        this.showSuggestions(brands)
      } else {
        this.hideSuggestions()
      }
    } catch (error) {
      console.error("Error fetching car brands:", error)
      this.hideSuggestions()
    }
  }

  handleBlur(event) {
    // Petit délai pour permettre le clic sur une suggestion
    setTimeout(() => {
      this.hideSuggestions()
    }, 200)
  }

  handleKeydown(event) {
    const suggestions = this.suggestionsTarget
    const items = suggestions.querySelectorAll("li")
    const currentIndex = Array.from(items).findIndex(item => item.classList.contains("bg-base-200"))

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (currentIndex < items.length - 1) {
          items[currentIndex]?.classList.remove("bg-base-200")
          items[currentIndex + 1].classList.add("bg-base-200")
          items[currentIndex + 1].scrollIntoView({ block: "nearest" })
        }
        break
      case "ArrowUp":
        event.preventDefault()
        if (currentIndex > 0) {
          items[currentIndex]?.classList.remove("bg-base-200")
          items[currentIndex - 1].classList.add("bg-base-200")
          items[currentIndex - 1].scrollIntoView({ block: "nearest" })
        }
        break
      case "Enter":
        event.preventDefault()
        const selectedItem = suggestions.querySelector("li.bg-base-200")
        if (selectedItem) {
          this.selectBrand(selectedItem.textContent)
        }
        break
      case "Escape":
        this.hideSuggestions()
        break
    }
  }

  selectBrand(brand) {
    this.inputTarget.value = brand
    this.hideSuggestions()
  }

  showSuggestions(brands) {
    const suggestions = this.suggestionsTarget
    suggestions.innerHTML = brands
      .map(brand => `<li class="px-4 py-2 hover:bg-base-200 cursor-pointer">${brand}</li>`)
      .join("")
    
    suggestions.classList.remove("hidden")
    
    // Ajouter les écouteurs d'événements pour les suggestions
    suggestions.querySelectorAll("li").forEach(item => {
      item.addEventListener("click", () => this.selectBrand(item.textContent))
    })
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
  }

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
} 