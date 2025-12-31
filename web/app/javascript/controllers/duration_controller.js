import { Controller } from "@hotwired/stimulus"

// Updates duration display in real-time while command is running
export default class extends Controller {
  static values = {
    startedAt: String,
    completedAt: String
  }

  connect() {
    if (this.isRunning) {
      this.startTimer()
    }
  }

  disconnect() {
    this.stopTimer()
  }

  startTimer() {
    this.updateDuration()
    this.timer = setInterval(() => this.updateDuration(), 1000)
  }

  stopTimer() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  updateDuration() {
    const duration = this.calculateDuration()
    this.element.textContent = `Duration: ${this.formatDuration(duration)}`
  }

  calculateDuration() {
    const startedAt = new Date(this.startedAtValue)
    const endTime = this.completedAtValue ? new Date(this.completedAtValue) : new Date()
    return (endTime - startedAt) / 1000
  }

  formatDuration(totalSeconds) {
    if (totalSeconds < 60) {
      return `${totalSeconds.toFixed(1)}s`
    }

    const hours = Math.floor(totalSeconds / 3600)
    const remainder = totalSeconds % 3600
    const minutes = Math.floor(remainder / 60)
    const seconds = Math.floor(remainder % 60)

    if (hours > 0) {
      return `${hours}h ${minutes}m ${seconds}s`
    }
    return `${minutes}m ${seconds}s`
  }

  get isRunning() {
    return this.startedAtValue && !this.completedAtValue
  }

  completedAtValueChanged() {
    if (this.completedAtValue) {
      this.stopTimer()
      this.updateDuration()
    }
  }
}
