// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import Chart from "chart.js/auto"
import { initHrmCharts } from "./hrm_charts"

document.addEventListener("turbo:load", () => {
  console.log("[HRM] turbo:load fired")
  initHrmCharts()
})