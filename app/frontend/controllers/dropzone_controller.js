import { Controller } from '@hotwired/stimulus'
import * as Turbo from '@hotwired/turbo'

export default class extends Controller {
  static targets = ['input', 'dropArea', 'loading']
  static values = {
    url: String
  }

  connect() {
    this.dragCounter = 0
  }

  dragEnter(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dragCounter++
    this.dropAreaTarget.classList.add('border-blue-500', 'bg-blue-50/50')
  }

  dragOver(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  dragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dragCounter--
    if (this.dragCounter <= 0) {
      this.dragCounter = 0
      this.dropAreaTarget.classList.remove('border-blue-500', 'bg-blue-50/50')
    }
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dragCounter = 0
    this.dropAreaTarget.classList.remove('border-blue-500', 'bg-blue-50/50')

    const files = event.dataTransfer?.files
    if (files && files.length > 0) {
      this.uploadFiles(files)
    }
  }

  fileSelected(event) {
    const files = event.target.files
    if (files && files.length > 0) {
      this.uploadFiles(files)
    }
  }

  async uploadFiles(fileList) {
    const validImageFiles = Array.from(fileList).filter(file => file.type.startsWith('image/'))
    if (validImageFiles.length === 0) {
      alert('Please upload valid image files (PNG, JPG, WEBP, GIF, etc.).')
      return
    }

    this.setLoading(true)

    const formData = new FormData()
    validImageFiles.forEach(file => {
      formData.append('images[]', file)
    })

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/json'
        },
        body: formData
      })

      if (response.ok) {
        const contentType = response.headers.get('content-type') || ''
        if (contentType.includes('text/vnd.turbo-stream.html')) {
          const streamMessage = await response.text()
          Turbo.renderStreamMessage(streamMessage)
        } else {
          // In case of standard page reload / redirect
          window.location.reload()
        }
      } else {
        const errText = await response.text()
        console.error('Upload failed:', errText)
        alert('Failed to upload image(s). Please try again.')
      }
    } catch (error) {
      console.error('Error during upload:', error)
      alert('An error occurred while uploading. Please try again.')
    } finally {
      if (this.hasInputTarget) {
        this.inputTarget.value = ''
      }
      this.setLoading(false)
    }
  }

  setLoading(isLoading) {
    if (this.hasLoadingTarget) {
      if (isLoading) {
        this.loadingTarget.classList.remove('hidden')
      } else {
        this.loadingTarget.classList.add('hidden')
      }
    }
  }
}
