import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["currentPrice", "bidsCount", "countdown"]
  static values = { id: Number, endsAt: String }

  connect() {
    this.endsAt = new Date(this.endsAtValue)
    this.startCountdown()
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.countdownInterval) clearInterval(this.countdownInterval)
    if (this.subscription) this.subscription.unsubscribe()
  }

  startCountdown() {
    this.updateCountdown()
    this.countdownInterval = setInterval(() => this.updateCountdown(), 1000)
  }

  updateCountdown() {
    const now = new Date()
    const diff = Math.max(0, Math.floor((this.endsAt - now) / 1000))

    if (diff === 0) {
      if (this.hasCountdownTarget) this.countdownTarget.textContent = "Terminée"
      clearInterval(this.countdownInterval)
      return
    }

    const days = Math.floor(diff / 86400)
    const hours = Math.floor((diff % 86400) / 3600)
    const minutes = Math.floor((diff % 3600) / 60)
    const seconds = diff % 60

    let text = ""
    if (days > 0) text += `${days}j `
    if (hours > 0 || days > 0) text += `${hours}h `
    text += `${minutes}m ${seconds}s`

    if (this.hasCountdownTarget) this.countdownTarget.textContent = text
  }

  subscribeToChannel() {
    const consumer = createConsumer()
    this.subscription = consumer.subscriptions.create(
      { channel: "AuctionChannel", id: this.idValue },
      {
        received: (data) => this.handleBroadcast(data)
      }
    )
  }

  handleBroadcast(data) {
    if (data.type === "new_bid") {
      if (this.hasCurrentPriceTarget) {
        this.currentPriceTarget.textContent = this.formatCurrency(data.auction.current_price)
      }
      if (this.hasBidsCountTarget) {
        this.bidsCountTarget.textContent = data.auction.bids_count
      }
      this.endsAt = new Date(data.auction.ends_at)
    }
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat("fr-FR", {
      style: "currency",
      currency: "EUR",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount)
  }
}
