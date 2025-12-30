import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["orgRef", "submit", "orgError"]
  static values = {
    commandsRequiringOrg: { type: Array, default: ["extract", "export", "migrate", "analysis", "tree"] }
  }

  connect() {
    this.validate()
  }

  validate() {
    const command = this.selectedCommand
    const orgRef = this.orgRefTarget.value.trim()
    const requiresOrg = this.commandsRequiringOrgValue.includes(command)

    if (requiresOrg && !orgRef) {
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.submitTarget.classList.remove("hover:bg-yellow-400", "cursor-pointer")
      this.orgErrorTarget.classList.remove("hidden")
    } else {
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitTarget.classList.add("hover:bg-yellow-400", "cursor-pointer")
      this.orgErrorTarget.classList.add("hidden")
    }
  }

  get selectedCommand() {
    const checked = this.element.querySelector('input[name="command"]:checked')
    return checked ? checked.value : ""
  }
}
