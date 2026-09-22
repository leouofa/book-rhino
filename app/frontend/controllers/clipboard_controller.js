import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['source', 'button']
  static values = {
    successDuration: { type: Number, default: 2000 }
  }

  copy(event) {
    if (event) event.preventDefault()

    const text = this.sourceTarget.textContent || this.sourceTarget.innerText || this.sourceTarget.value || ''
    const cleanText = text.trim()

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(cleanText).then(() => {
        this.showCopiedState()
      }).catch(err => {
        console.error('Failed to copy text using clipboard API: ', err)
        this.fallbackCopy(cleanText)
      })
    } else {
      this.fallbackCopy(cleanText)
    }
  }

  fallbackCopy(text) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.top = '-9999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      document.execCommand('copy')
      this.showCopiedState()
    } catch (err) {
      console.error('Fallback copy failed: ', err)
    } finally {
      document.body.removeChild(textArea)
    }
  }

  showCopiedState() {
    if (!this.hasButtonTarget) return

    const button = this.buttonTarget
    const originalText = button.dataset.originalText || button.textContent

    if (!button.dataset.originalText) {
      button.dataset.originalText = originalText
    }

    button.textContent = 'Copied!'
    button.classList.add('!bg-emerald-600')

    setTimeout(() => {
      button.textContent = button.dataset.originalText
      button.classList.remove('!bg-emerald-600')
    }, this.successDurationValue)
  }
}
