import Chart from "chart.js/auto"

const charts = new WeakMap()

const hasChartJs = () => typeof Chart !== "undefined"

const buildLineChart = (canvas, data, options) => {
  if (!hasChartJs()) {
    console.warn("[HRM Charts] Chart.js not available.")
    return
  }
  const ctx = canvas.getContext("2d")
  if (!ctx) return

  const existing = charts.get(canvas)
  if (existing) existing.destroy()

  const chart = new Chart(ctx, { type: "line", data, options })
  charts.set(canvas, chart)
}

const fetchPoints = async (url) => {
  if (!url) return []
  const response = await fetch(url, { headers: { Accept: "application/json" } })
  if (!response.ok) return []
  const payload = await response.json()
  return payload.points || []
}

export const renderSessionChart = async (canvas, url) => {
  if (!canvas) return
  if (!hasChartJs()) return
  if (!url) return

  console.info("[HRM Charts] Rendering session chart", url)
  const points = await fetchPoints(url)
  if (!points.length) return

  const labels = points.map((point) => point.x)
  const values = points.map((point) => point.y)

  buildLineChart(
    canvas,
    {
      labels,
      datasets: [
        {
          data: values,
          borderColor: "#4f46e5",
          backgroundColor: "rgba(79, 70, 229, 0.12)",
          borderWidth: 2,
          tension: 0.3,
          pointRadius: 0,
          fill: true
        }
      ]
    },
    {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: { maxTicksLimit: 6, color: "#6b7280" }
        },
        y: {
          grid: { color: "rgba(0, 0, 0, 0.06)" },
          ticks: { maxTicksLimit: 5, color: "#6b7280" }
        }
      }
    }
  )
}

export const renderSparkline = async (canvas, url) => {
  if (!canvas) return
  if (!hasChartJs()) return
  if (!url) return

  console.info("[HRM Charts] Rendering sparkline", url)
  const points = await fetchPoints(url)
  if (!points.length) return

  const labels = points.map((point) => point.x)
  const values = points.map((point) => point.y)

  buildLineChart(
    canvas,
    {
      labels,
      datasets: [
        {
          data: values,
          borderColor: "#6b7280",
          backgroundColor: "rgba(107, 114, 128, 0.1)",
          borderWidth: 1.5,
          tension: 0.35,
          pointRadius: 0,
          fill: false
        }
      ]
    },
    {
      responsive: true,
      maintainAspectRatio: false,
      animation: false,
      plugins: {
        legend: { display: false },
        tooltip: { enabled: false }
      },
      scales: {
        x: { display: false },
        y: { display: false }
      }
    }
  )
}

export const renderZoneChart = (canvas, zones) => {
  if (!canvas) return
  if (!hasChartJs()) return
  if (!zones) return

  console.info("[HRM Charts] Rendering zone chart")
  const labels = Object.keys(zones).map((zone) => zone.toUpperCase())
  const values = Object.values(zones).map((value) => Number(value) || 0)

  const ctx = canvas.getContext("2d")
  if (!ctx) return

  const existing = charts.get(canvas)
  if (existing) existing.destroy()

  const chart = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets: [
        {
          data: values,
          backgroundColor: ["#6366f1", "#818cf8", "#a5b4fc", "#c7d2fe"],
          borderRadius: 6
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: { color: "#6b7280" }
        },
        y: {
          beginAtZero: true,
          grid: { color: "rgba(0, 0, 0, 0.06)" },
          ticks: { color: "#6b7280", callback: (value) => `${value}%` }
        }
      }
    }
  })

  charts.set(canvas, chart)
}

export const initHrmCharts = () => {
  if (!hasChartJs()) {
    console.warn("[HRM Charts] Chart.js not available on init.")
    return
  }

  const canvases = document.querySelectorAll("canvas[data-hrm-chart]")
  console.info(`[HRM Charts] Initializing ${canvases.length} chart(s).`)

  canvases.forEach((canvas) => {
    if (canvas.dataset.hrmRendered === "true") return

    const type = canvas.dataset.hrmChart
    if (type === "session" || type === "sparkline") {
      const url = canvas.dataset.hrmUrl
      if (!url) {
        console.warn("[HRM Charts] Missing data-hrm-url for", type)
        return
      }

      const renderer = type === "session" ? renderSessionChart : renderSparkline
      renderer(canvas, url).then(() => {
        canvas.dataset.hrmRendered = "true"
      })
      return
    }

    if (type === "zones") {
      const rawZones = canvas.dataset.zones
      if (!rawZones) {
        console.warn("[HRM Charts] Missing data-zones for zone chart")
        return
      }
      try {
        const zones = JSON.parse(rawZones)
        renderZoneChart(canvas, zones)
        canvas.dataset.hrmRendered = "true"
      } catch (_error) {
        console.warn("[HRM Charts] Invalid zone data JSON")
        return
      }
    }
  })
}
