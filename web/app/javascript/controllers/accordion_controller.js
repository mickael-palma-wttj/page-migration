import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle(event) {
    const button = event.currentTarget
    const content = button.nextElementSibling
    const icon = button.querySelector("[data-accordion-target='icon']")

    if (content.classList.contains("hidden")) {
      // Open: show content and rotate arrow to point down
      content.classList.remove("hidden")
      if (icon) {
        icon.style.transform = "rotate(90deg)"
      }
    } else {
      // Close: hide content and rotate arrow to point right
      content.classList.add("hidden")
      if (icon) {
        icon.style.transform = "rotate(0deg)"
      }
    }
  }
}
