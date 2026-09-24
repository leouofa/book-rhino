import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['source', 'button']
  static values = {
    successDuration: { type: Number, default: 2000 },
    backgroundPrompt: { type: String, default: '' }
  }

  copy(event) {
    if (event) event.preventDefault()

    const button = (event && event.currentTarget) ? event.currentTarget : (this.hasButtonTarget ? this.buttonTarget : null)
    const text = this.sourceTarget.innerText || this.sourceTarget.textContent || this.sourceTarget.value || ''
    const cleanText = text.trim()

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(cleanText).then(() => {
        this.showCopiedState(button)
      }).catch(err => {
        console.error('Failed to copy text using clipboard API: ', err)
        this.fallbackCopy(cleanText, button)
      })
    } else {
      this.fallbackCopy(cleanText, button)
    }
  }

  copyFormatted(event) {
    if (event) event.preventDefault()

    const button = (event && event.currentTarget) ? event.currentTarget : (this.hasButtonTarget ? this.buttonTarget : null)
    const text = this.sourceTarget.innerText || this.sourceTarget.textContent || this.sourceTarget.value || ''
    const cleanText = text.trim()
    const prompt = this.backgroundPromptValue || ''
    const formattedText = `\`\`\`\n${cleanText}\n\`\`\`\n-----\n${prompt}`

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(formattedText).then(() => {
        this.showCopiedState(button)
      }).catch(err => {
        console.error('Failed to copy text using clipboard API: ', err)
        this.fallbackCopy(formattedText, button)
      })
    } else {
      this.fallbackCopy(formattedText, button)
    }
  }

  fallbackCopy(text, button) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.top = '-9999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      document.execCommand('copy')
      this.showCopiedState(button)
    } catch (err) {
      console.error('Fallback copy failed: ', err)
    } finally {
      document.body.removeChild(textArea)
    }
  }

  showCopiedState(buttonOverride) {
    const button = buttonOverride || (this.hasButtonTarget ? this.buttonTarget : null)
    if (!button) return
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
