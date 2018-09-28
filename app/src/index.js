import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

import * as CodeMirror from "codemirror/lib/codemirror"
import "codemirror/mode/nginx/nginx"

class CodeMirrorEditorElement extends HTMLElement {
    connectedCallback() {
        this.editor = CodeMirror(this, {
            value: this._val || '',
            indentUnit: 4,
            lineNumbers: true,
            mode: "text/x-nginx-conf",
            viewportMargin: Infinity
        })
        this.editor.on('changes', (instance, changes) => {
            this._val = this.editor.getValue()
            this.dispatchEvent(new CustomEvent('editorChanged'))
        })
    }

    get editorValue() {
        return this._val
    }

    set editorValue(val) {
        if (this._val === val) return
        this._val = val
        if (this.editor) {
            this.editor.setValue(val)
        }
    }
}

customElements.define('code-mirror-editor', CodeMirrorEditorElement)

Elm.Main.init({
    node: document.getElementById('root')
});

registerServiceWorker();
