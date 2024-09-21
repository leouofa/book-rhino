import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["button", "textarea"]

  connect() {
    // Only call toggleButtonState if textareaTarget is present
    if (this.hasTextareaTarget) {
      this.toggleButtonState()
    }
  }

  toggleButtonState() {
    const message = this.textareaTarget.value.trim()
    this.buttonTarget.disabled = message.length === 0
  }

  onInput() {
    this.toggleButtonState()
  }

  submit(e) {
    this.buttonTarget.disabled = true
  }
}
