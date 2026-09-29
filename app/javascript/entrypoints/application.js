import '~/application.css'
import { createApp } from 'vue'
import ApexCharts from 'apexcharts'
import { formatCurrency } from '~/currency'

// Islands: any <div data-vue-component="ProductForm"> on the page gets that
// component from app/javascript/components mounted into it, with its
// data-props (JSON) passed in as props. Lets HAML pages stay plain HTML and
// only pull in Vue where a form/page actually needs it.
const components = import.meta.glob('~/components/*.vue', { eager: true })

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-vue-component]').forEach((el) => {
    const name = el.dataset.vueComponent
    const mod = components[`/components/${name}.vue`]
    if (!mod) {
      console.error(`Vue component "${name}" not found in app/javascript/components`)
      return
    }
    const props = el.dataset.props ? JSON.parse(el.dataset.props) : {}
    createApp(mod.default, props).mount(el)
  })

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const isDark = document.documentElement.classList.toggle('dark')
      try {
        localStorage.setItem('theme', isDark ? 'dark' : 'light')
      } catch (e) {}
    })
  })

  const sidebar = document.getElementById('sidebar')
  const backdrop = document.querySelector('[data-sidebar-backdrop]')
  if (sidebar && backdrop) {
    const closeSidebar = () => {
      sidebar.classList.add('-translate-x-full')
      backdrop.classList.add('hidden')
    }
    document.querySelectorAll('[data-sidebar-toggle]').forEach((el) => {
      el.addEventListener('click', () => {
        sidebar.classList.remove('-translate-x-full')
        backdrop.classList.remove('hidden')
      })
    })
    backdrop.addEventListener('click', closeSidebar)
  }

  renderCharts()
})

// Dashboard charts read their data from `gon` (pushed by DashboardController,
// same shape the presenter also formats for) and their color from the
// --color-accent custom property, so they follow whichever theme was active
// on page load without duplicating the design tokens in JS.
function renderCharts() {
  const monthlySalesEl = document.querySelector('[data-chart="monthly-sales"]')
  // Vite's dev-mode HMR client can re-run this module without a full page
  // navigation (e.g. after an autoBuild triggered by editing a watched
  // .haml file), which would otherwise mount a second ApexCharts instance
  // on top of the first. Guard on a marker attribute instead of assuming
  // renderCharts() only ever runs once per document.
  if (monthlySalesEl && !monthlySalesEl.dataset.chartRendered && window.gon?.monthly_sales_chart) {
    monthlySalesEl.dataset.chartRendered = 'true'
    const { categories, series } = window.gon.monthly_sales_chart
    new ApexCharts(monthlySalesEl, {
      ...baseChartOptions(),
      chart: { ...baseChartOptions().chart, type: 'line', height: 280 },
      series: [{ name: monthlySalesEl.dataset.seriesLabel, data: series }],
      xaxis: { categories, labels: { style: { colors: axisColor() } } },
      yaxis: { labels: { style: { colors: axisColor() }, formatter: (value) => formatCurrency(value) } },
      tooltip: { ...baseChartOptions().tooltip, y: { formatter: (value) => formatCurrency(value) } },
      stroke: { curve: 'smooth', width: 2 },
    }).render()
  }

  const topProductsEl = document.querySelector('[data-chart="top-products"]')
  if (topProductsEl && !topProductsEl.dataset.chartRendered && window.gon?.top_products_chart) {
    topProductsEl.dataset.chartRendered = 'true'
    const { categories, series } = window.gon.top_products_chart
    new ApexCharts(topProductsEl, {
      ...baseChartOptions(),
      chart: { ...baseChartOptions().chart, type: 'bar', height: Math.max(160, categories.length * 48) },
      plotOptions: { bar: { horizontal: true, borderRadius: 2, barHeight: '55%' } },
      series: [{ name: topProductsEl.dataset.seriesLabel, data: series }],
      xaxis: { categories, labels: { style: { colors: axisColor() } } },
    }).render()
  }
}

function baseChartOptions() {
  return {
    chart: { toolbar: { show: false }, fontFamily: 'IBM Plex Sans, sans-serif', foreColor: axisColor() },
    colors: [accentColor()],
    dataLabels: { enabled: false },
    grid: { borderColor: lineColor(), strokeDashArray: 3 },
    tooltip: { theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light' },
  }
}

function cssVar(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
}

function accentColor() {
  return cssVar('--color-accent')
}

function axisColor() {
  return cssVar('--color-ink-muted')
}

function lineColor() {
  return cssVar('--color-line')
}
