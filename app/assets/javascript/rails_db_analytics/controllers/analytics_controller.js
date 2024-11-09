// analytics controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["modal"]

  connect() {
    console.log("Analytics Controller Connected")
  }

  openModal() {
    this.modalOutlet.open()
  }
}
