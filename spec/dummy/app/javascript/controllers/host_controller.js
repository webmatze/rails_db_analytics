import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Connected")
    this.element.textContent = "Hello World! This is a Javascript from the Host"
  }
}

console.log("Host Controller Loaded")
