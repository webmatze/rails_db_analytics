import { Application } from "@hotwired/stimulus"
import { Chart } from "chart.js"

// Initialize Stimulus application
const application = Application.start()

// Configure Chart.js defaults
Chart.defaults.font.family = "'Inter var', sans-serif"
Chart.defaults.color = "#374151" // text-gray-700
Chart.defaults.borderColor = "#E5E7EB" // border-gray-200
// Chart.defaults.plugins.tooltip.backgroundColor = "#1F2937" // bg-gray-800
// Chart.defaults.plugins.legend.labels.usePointStyle = true

import ModalController from "controllers/modal_controller"
import ChartController from "controllers/chart_controller"
import AnalyticsController from "controllers/analytics_controller"

application.register("modal", ModalController)
application.register("chart", ChartController)
application.register("analytics", AnalyticsController)

// Export for use in host application
export { application }