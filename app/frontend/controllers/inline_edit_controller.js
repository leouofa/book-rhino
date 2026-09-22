import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'input', 'form']
  static values = {
    url: String,
    attribute: { type: String, default: 'title' },
    paramKey: { type: String, default: '' }
  }

  connect() {
    this.originalValue = this.inputTarget.value
  }

  startEditing() {
    this.originalValue = this.inputTarget.value
    this.displayTarget.classList.add('hidden')
    this.formTarget.classList.remove('hidden')
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  cancel() {
    this.inputTarget.value = this.originalValue
    this.displayTarget.classList.remove('hidden')
    this.formTarget.classList.add('hidden')
  }

  handleKeyDown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.save()
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.cancel()
    }
  }

  blurInput() {
    // If the form is currently visible, save on blur
    if (!this.formTarget.classList.contains('hidden')) {
      this.save()
    }
  }

  async save() {
    const newValue = this.inputTarget.value.trim()

    if (!newValue) {
      this.cancel()
      return
    }

    if (newValue === this.originalValue) {
      this.displayTarget.classList.remove('hidden')
      this.formTarget.classList.add('hidden')
      return
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      let body
      if (this.hasParamKeyValue && this.paramKeyValue) {
        body = {
          [this.paramKeyValue]: {
            [this.attributeValue]: newValue
          }
        }
      } else {
        body = {
          [this.attributeValue]: newValue,
          character_image: { [this.attributeValue]: newValue },
          location_image: { [this.attributeValue]: newValue }
        }
      }

      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json, text/vnd.turbo-stream.html'
        },
        body: JSON.stringify(body)
      })

      if (response.ok) {
        this.originalValue = newValue
        this.displayTarget.textContent = newValue
      } else {
        console.error('Failed to update title')
        this.inputTarget.value = this.originalValue
      }
    } catch (err) {
      console.error('Error updating title:', err)
      this.inputTarget.value = this.originalValue
    } finally {
      this.displayTarget.classList.remove('hidden')
      this.formTarget.classList.add('hidden')
    }
  }
}
