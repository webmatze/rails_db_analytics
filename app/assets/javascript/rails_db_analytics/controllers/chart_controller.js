import { Controller } from "@hotwired/stimulus"
import { Chart, BarController, CategoryScale, LinearScale, BarElement } from 'chart.js'

// Register the required components
Chart.register(BarController, CategoryScale, LinearScale, BarElement)

export default class extends Controller {
  static targets = ["canvas"]

  connect() {
    this.initializeChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  initializeChart() {
    const canvas = this.canvasTarget
    const data = JSON.parse(canvas.dataset.chartData)
    
    if (data) {
      this.createChart(canvas, data)
    }
  }

  extractChartableData(data) {
    // Look for the first set of numeric data that can be charted
    for (const [key, value] of Object.entries(data)) {
      if (this.isChartableData(value)) {
        return this.formatChartData(key, value)
      }
    }
    return null
  }

  isChartableData(value) {
    if (typeof value === "object") {
      // Check if it's an object with numeric values
      return Object.values(value).every(v => typeof v === "number")
    }
    return false
  }

  formatChartData(label, data) {
    const backgroundColor = [
      'rgba(59, 130, 246, 0.5)', // blue
      'rgba(16, 185, 129, 0.5)', // green
      'rgba(249, 115, 22, 0.5)', // orange
      'rgba(236, 72, 153, 0.5)', // pink
      'rgba(139, 92, 246, 0.5)'  // purple
    ]

    if (Array.isArray(data)) {
      return {
        labels: data.map((_, index) => `Item ${index + 1}`),
        datasets: [{
          label,
          data,
          backgroundColor
        }]
      }
    } else {
      return {
        labels: Object.keys(data),
        datasets: [{
          label,
          data: Object.values(data),
          backgroundColor
        }]
      }
    }
  }

  createChart(canvas, data) {
    this.chart = new Chart(canvas, {type: 'bar', data: data})
  }
}
