import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["registration", "vin", "make", "model", "year", "fuelType", "transmission", "doors", "seats"]
  static values = {
    url: String
  }

  connect() {
    console.log("Vehicle autocomplete controller connected")
  }

  async lookupByRegistration() {
    const registration = this.registrationTarget.value
    if (registration.length < 7) return

    try {
      const response = await fetch(`${this.urlValue}?registration=${encodeURIComponent(registration)}`)
      const data = await response.json()
      
      if (data.error) {
        console.error(data.error)
        return
      }

      this.fillForm(data)
    } catch (error) {
      console.error("Error fetching vehicle data:", error)
    }
  }

  async lookupByVin() {
    const vin = this.vinTarget.value
    if (vin.length < 17) return

    try {
      const response = await fetch(`${this.urlValue}?vin=${encodeURIComponent(vin)}`)
      const data = await response.json()
      
      if (data.error) {
        console.error(data.error)
        return
      }

      this.fillForm(data)
    } catch (error) {
      console.error("Error fetching vehicle data:", error)
    }
  }

  fillForm(data) {
    if (this.hasMakeTarget) this.makeTarget.value = data.make
    if (this.hasModelTarget) this.modelTarget.value = data.model
    if (this.hasYearTarget) this.yearTarget.value = data.year
    if (this.hasFuelTypeTarget) this.fuelTypeTarget.value = data.fuel_type
    if (this.hasTransmissionTarget) this.transmissionTarget.value = data.transmission
    if (this.hasDoorsTarget) this.doorsTarget.value = data.doors
    if (this.hasSeatsTarget) this.seatsTarget.value = data.seats
  }
} 