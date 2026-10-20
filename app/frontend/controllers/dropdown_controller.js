import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = []

  initialize() {
    // Called once, when the controller is first instantiated
  }

  connect() {
    $('.dropdown', this.element).each((_, el) => {
      const isClearable = el.classList.contains('clearable') || $(el).data('clearable') === true;
      $(el).dropdown({
        clearable: isClearable,
        placeholder: isClearable ? false : 'auto'
      });
    });
  }

  disconnect() {
    $('.dropdown', this.element).dropdown('destroy')
  }
}
