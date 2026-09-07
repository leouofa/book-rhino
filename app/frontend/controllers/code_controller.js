import { Controller } from '@hotwired/stimulus'
import { EditorView, basicSetup } from 'codemirror'
import { keymap } from '@codemirror/view'
import { indentLess, indentMore } from '@codemirror/commands'
import { yaml } from '@codemirror/lang-yaml'

export default class extends Controller {
  connect() {
    this.textarea = this.element

    this.view = new EditorView({
      doc: this.textarea.value,
      extensions: [
        basicSetup,
        yaml(),
        EditorView.lineWrapping,
        keymap.of([
          { key: 'Tab', run: indentMore },
          { key: 'Shift-Tab', run: indentLess },
        ]),
        EditorView.theme({
          '&': { height: '800px' },
          '.cm-scroller': { overflow: 'auto' },
        }),
        EditorView.updateListener.of((update) => {
          this.textarea.value = update.state.doc.toString()
        }),
      ],
    })

    this.textarea.style.display = 'none'
    this.textarea.insertAdjacentElement('afterend', this.view.dom)
  }

  disconnect() {
    this.textarea.style.display = ''
    this.view?.destroy()
  }
}
