import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "licensePlate", "licensePlateError",
    "vin", "vinError",
    "make", "model", "fiscalPower",
    "averageConsumption", "co2Emissions"
  ]
  
  connect() {
    this.licensePlatePattern = /^[A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2}$/
    this.vinPattern = /^[A-HJ-NPR-Z0-9]{17}$/
  }
  
  validateLicensePlate() {
    const value = this.licensePlateTarget.value.toUpperCase()
    const isValid = this.licensePlatePattern.test(value)
    
    this.licensePlateErrorTarget.textContent = isValid ? "" : "Format invalide (ex: AA-123-AA)"
    this.licensePlateErrorTarget.classList.toggle("hidden", isValid)
    
    return isValid
  }
  
  validateVin() {
    const value = this.vinTarget.value.toUpperCase()
    const isValid = this.vinPattern.test(value)
    
    this.vinErrorTarget.textContent = isValid ? "" : "Le numéro VIN doit contenir exactement 17 caractères"
    this.vinErrorTarget.classList.toggle("hidden", isValid)
    
    return isValid
  }
  
  async fetchInfo(event) {
    const target = event.target
    const value = target.value.trim()
    
    if (value.length === 0) return
    
    let isValid = false
    let endpoint = ""
    
    if (target === this.licensePlateTarget) {
      isValid = this.validateLicensePlate()
      endpoint = `/vehicles/fetch_info?license_plate=${encodeURIComponent(value)}`
    } else if (target === this.vinTarget) {
      isValid = this.validateVin()
      endpoint = `/vehicles/fetch_info?vin=${encodeURIComponent(value)}`
    }
    
    if (!isValid) return
    
    try {
      const response = await fetch(endpoint)
      const data = await response.json()
      
      if (response.ok) {
        this.fillVehicleInfo(data)
      } else {
        console.error("Erreur lors de la récupération des informations:", data.error)
      }
    } catch (error) {
      console.error("Erreur lors de la requête:", error)
    }
  }
  
  fillVehicleInfo(data) {
    if (data.make) this.makeTarget.value = data.make
    if (data.model) this.modelTarget.value = data.model
    if (data.fiscal_power) this.fiscalPowerTarget.value = data.fiscal_power
    if (data.average_consumption) this.averageConsumptionTarget.value = data.average_consumption
    if (data.co2_emissions) this.co2EmissionsTarget.value = data.co2_emissions
  }
} 