// modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["dialog"]

    connect() {
        this.dialogTarget.addEventListener('transitionend', this.handleTransitionEnd)
    }

    disconnect() {
        this.dialogTarget.removeEventListener('transitionend', this.handleTransitionEnd)
    }

    open(e) {
        e.preventDefault()
        this.dialogTarget.showModal()
        requestAnimationFrame(() => {
            this.dialogTarget.classList.remove('invisible')
            this.dialogTarget.classList.add('opacity-100')
        })
    }

    close(e) {
        if (e) e.preventDefault()
        this.dialogTarget.classList.remove('opacity-100')
        this.dialogTarget.addEventListener('transitionend', () => {
            this.dialogTarget.close()
            this.dialogTarget.classList.add('invisible')
        }, { once: true })
    }

    clickOutside(e) {
        if (e.target === this.dialogTarget) this.close(e)
    }

    handleTransitionEnd = (e) => {
        if (e.propertyName === 'opacity' && !this.dialogTarget.classList.contains('opacity-100')) {
            this.dialogTarget.close()
        }
    }
}