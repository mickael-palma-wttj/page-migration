import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "results", "display"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 }
  }

  connect() {
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
    this.results = []
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideResults()
      return
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchResults(query), 200)
  }

  async fetchResults(query) {
    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("q", query)

      const response = await fetch(url, {
        headers: { "Accept": "application/json" }
      })

      if (!response.ok) throw new Error("Network error")

      this.results = await response.json()
      this.renderResults()
    } catch (error) {
      console.error("Autocomplete error:", error)
      this.hideResults()
    }
  }

  renderResults() {
    if (this.results.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-wttj-gray-medium">
          No organizations found
        </div>
      `
      this.showResults()
      return
    }

    this.resultsTarget.innerHTML = this.results.map((org, index) => `
      <div class="autocomplete-item px-4 py-3 cursor-pointer hover:bg-wttj-beige transition-colors ${index === this.selectedIndex ? 'bg-wttj-beige' : ''}"
           data-action="click->autocomplete#select"
           data-index="${index}">
        <div class="flex items-center gap-3">
          <span class="font-mono text-sm bg-wttj-beige px-2 py-0.5 rounded border border-wttj-gray-light">
            ${this.escapeHtml(org.reference)}
          </span>
          <span class="text-wttj-black">${this.escapeHtml(org.name)}</span>
        </div>
      </div>
    `).join("")

    this.showResults()
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    const org = this.results[index]

    if (org) {
      this.hiddenTarget.value = org.reference
      this.inputTarget.value = `${org.reference} - ${org.name}`
      this.displayTarget.textContent = org.name
      this.displayTarget.classList.remove("hidden")
      // Dispatch event for other controllers to react
      this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }

    this.hideResults()
  }

  keydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.results.length - 1)
        this.renderResults()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.renderResults()
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0 && this.results[this.selectedIndex]) {
          const org = this.results[this.selectedIndex]
          this.hiddenTarget.value = org.reference
          this.inputTarget.value = `${org.reference} - ${org.name}`
          this.displayTarget.textContent = org.name
          this.displayTarget.classList.remove("hidden")
          this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
          this.hideResults()
        }
        break
      case "Escape":
        this.hideResults()
        break
    }
  }

  blur() {
    // Delay to allow click events to fire
    setTimeout(() => this.hideResults(), 150)
  }

  focus() {
    if (this.inputTarget.value.length >= this.minLengthValue && this.results.length > 0) {
      this.showResults()
    }
  }

  clear() {
    this.hiddenTarget.value = ""
    this.inputTarget.value = ""
    this.displayTarget.textContent = ""
    this.displayTarget.classList.add("hidden")
    this.hideResults()
    this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.inputTarget.focus()
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
