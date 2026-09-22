import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'image']
  static values = {
    imageUrl: String,
    successDuration: { type: Number, default: 2000 }
  }

  async copy(event) {
    if (event) event.preventDefault()

    const imageUrl = this.imageUrlValue || (this.hasImageTarget ? this.imageTarget.src : null)
    if (!imageUrl) {
      console.error('No image URL available to copy')
      return
    }

    try {
      // Load image into an Image element and draw to canvas to ensure standard image/png blob
      const img = new Image()
      img.crossOrigin = 'anonymous'
      img.src = imageUrl

      await new Promise((resolve, reject) => {
        if (img.complete && img.naturalWidth !== 0) {
          resolve()
        } else {
          img.onload = resolve
          img.onerror = reject
        }
      })

      const canvas = document.createElement('canvas')
      canvas.width = img.naturalWidth
      canvas.height = img.naturalHeight
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0)

      const pngBlob = await new Promise(resolve => canvas.toBlob(resolve, 'image/png'))
      if (!pngBlob) {
        throw new Error('Failed to generate PNG blob from image')
      }

      await navigator.clipboard.write([
        new ClipboardItem({
          'image/png': pngBlob
        })
      ])

      this.showCopiedState()
    } catch (err) {
      console.error('Failed to copy image to clipboard: ', err)
      // Fallback: try copying image URL
      if (navigator.clipboard && navigator.clipboard.writeText) {
        try {
          await navigator.clipboard.writeText(imageUrl)
          this.showCopiedState('URL Copied!')
        } catch (copyErr) {
          console.error('Fallback URL copy failed:', copyErr)
          alert('Failed to copy image to clipboard.')
        }
      } else {
        alert('Failed to copy image to clipboard.')
      }
    }
  }

  showCopiedState(text = 'Copied!') {
    if (!this.hasButtonTarget) return

    const button = this.buttonTarget
    const originalText = button.dataset.originalText || button.textContent

    if (!button.dataset.originalText) {
      button.dataset.originalText = originalText
    }

    button.textContent = text
    button.classList.add('!bg-emerald-600')

    setTimeout(() => {
      button.textContent = button.dataset.originalText
      button.classList.remove('!bg-emerald-600')
    }, this.successDurationValue)
  }
}
