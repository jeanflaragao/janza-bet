import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    async showForm(event) {
        event.preventDefault()
        console.log("Fetching form from:", this.urlValue)

        const response = await fetch(this.urlValue, {
            headers: { Accept: "text/vnd.turbo-stream.html" }
        })

        const html = await response.text()
        console.log("Turbo stream HTML:", html)
        Turbo.renderStreamMessage(html)
    }
}
