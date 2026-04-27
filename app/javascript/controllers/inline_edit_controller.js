import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    edit(event) {
        event.preventDefault()
        event.stopPropagation()
        fetch(this.urlValue, {
            headers: { Accept: "text/vnd.turbo-stream.html" }
        })
        .then(r => r.text())
        .then(html => Turbo.renderStreamMessage(html))
    }

    noOp(event) {
        event.stopPropagation()
    }
}
