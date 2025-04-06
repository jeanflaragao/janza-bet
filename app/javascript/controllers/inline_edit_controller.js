import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    showForm() {
        if (this.urlValue) {
            Turbo.visit(this.urlValue, { frame: this.element.closest("turbo-frame").id })
        }
    }
}