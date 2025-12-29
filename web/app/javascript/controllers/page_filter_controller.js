import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "page", "count"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.pageTargets.forEach(page => {
      const slug = page.dataset.slug?.toLowerCase() || ""
      const content = page.dataset.content?.toLowerCase() || ""

      if (query === "" || slug.includes(query) || content.includes(query)) {
        page.classList.remove("hidden")
        visibleCount++
      } else {
        page.classList.add("hidden")
      }
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = `${visibleCount} / ${this.pageTargets.length}`
    }
  }

  clear() {
    this.inputTarget.value = ""
    this.filter()
  }
}
