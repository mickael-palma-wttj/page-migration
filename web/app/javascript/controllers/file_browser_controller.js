import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["breadcrumb", "fileList", "fileItem", "folderItem"]
  static values = {
    currentPath: String,
    rootLabel: { type: String, default: "root" },
    darkMode: { type: Boolean, default: false }
  }

  connect() {
    this.currentPathValue = ""
    this.updateView()
  }

  navigate(event) {
    event.preventDefault()
    const path = event.currentTarget.dataset.path || ""
    this.currentPathValue = path
    this.updateView()
  }

  updateView() {
    const currentPath = this.currentPathValue

    // Update breadcrumb
    this.updateBreadcrumb(currentPath)

    // Show/hide items based on current path
    this.fileItemTargets.forEach(item => {
      const itemPath = item.dataset.filePath
      const itemDir = item.dataset.fileDir || ""

      if (currentPath === itemDir) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })

    this.folderItemTargets.forEach(item => {
      const folderPath = item.dataset.folderPath
      const folderParent = item.dataset.folderParent || ""

      if (currentPath === folderParent) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }

  updateBreadcrumb(currentPath) {
    const parts = currentPath ? currentPath.split("/") : []
    const rootLabel = this.rootLabelValue
    const isDark = this.darkModeValue

    // Color classes based on theme
    const activeClass = isDark ? "text-white font-medium" : "text-wttj-black font-medium"
    const inactiveClass = isDark ? "text-wttj-gray-light" : "text-wttj-gray-dark"
    const hoverClass = isDark ? "hover:text-wttj-yellow" : "hover:text-wttj-black"
    const separatorClass = isDark ? "text-wttj-gray-medium" : "text-wttj-gray-medium"

    let html = `<button type="button" data-action="click->file-browser#navigate" data-path="" class="${hoverClass} ${currentPath === "" ? activeClass : inactiveClass}">${rootLabel}</button>`

    let accumulated = ""
    parts.forEach((part, index) => {
      accumulated = accumulated ? `${accumulated}/${part}` : part
      const isLast = index === parts.length - 1
      html += ` <span class="${separatorClass}">/</span> `
      html += `<button type="button" data-action="click->file-browser#navigate" data-path="${accumulated}" class="${hoverClass} ${isLast ? activeClass : inactiveClass}">${part}</button>`
    })

    this.breadcrumbTarget.innerHTML = html
  }
}
