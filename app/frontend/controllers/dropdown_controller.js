import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = []

  initialize() {
    // Called once, when the controller is first instantiated
  }

  connect() {
    $('.dropdown', this.element).dropdown()
  }

  disconnect() {
    // Called any time the controller is disconnected from the DOM
  }
}