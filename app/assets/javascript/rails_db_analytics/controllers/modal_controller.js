import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add event listener for ESC key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close()
      }
    })
  }

  open() {
    this.element.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
  }

  close() {
    this.element.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
  }

  // Close modal when clicking outside
  click(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
