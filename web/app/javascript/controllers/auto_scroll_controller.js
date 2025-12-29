import { Controller } from "@hotwired/stimulus"

// Automatically scrolls to bottom when content changes
export default class extends Controller {
  static targets = ["output"]

  connect() {
    this.scrollToBottom()
    this.observeChanges()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  observeChanges() {
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    // Observe the element for content changes
    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
      characterData: true
    })
  }

  scrollToBottom() {
    if (this.hasOutputTarget) {
      this.outputTarget.scrollTop = this.outputTarget.scrollHeight
    }
  }
}
